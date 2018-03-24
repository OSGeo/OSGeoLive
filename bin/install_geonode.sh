#!/bin/sh
#############################################################################
#
# Purpose: This script will install GeoNode
#
#############################################################################
# Copyright (c) 2013-2016 Open Source Geospatial Foundation (OSGeo) and others.
#
# Licensed under the GNU LGPL version >= 2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

echo "Starting GeoNode installation"

if [ -z "$USER_NAME" ] ; then
    USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"
DATA_DIR="/usr/local/share/geonode"
DOC_DIR="$DATA_DIR/doc"
APACHE_CONF="/etc/apache2/sites-available/geonode.conf"
GEONODE_DB="geonode_app"
GEONODE_STORE="geonode_data"
GEOSERVER_VERSION="2.10.4"
GEOSERVER_PATH="/usr/local/lib/geoserver-$GEOSERVER_VERSION"
GEONODE_BIN_FOLDER="/usr/local/share/geonode"
GEONODE_DIR="/usr/lib/python2.7/dist-packages/geonode"
STATIC_PATH="/var/www/geonode/static"
UPLOAD_PATH="/var/www/geonode/uploaded"

# Install packages
add-apt-repository -y ppa:geonode/osgeo
apt-get -q update

apt-get install --assume-yes --no-install-recommends python-geonode libapache2-mod-wsgi curl
#apt-mark hold python-geonode

if [ $? -ne 0 ] ; then
    echo 'ERROR: Package install failed! Aborting.'
    exit 1
fi

# Add an entry in /etc/hosts for geonode, to enable http://geonode/
echo '127.0.0.1 geonode' | sudo tee -a /etc/hosts

# Deploy demonstration instance in Apache
echo "Deploying geonode demonstration instance"
cat << EOF > "$APACHE_CONF"
WSGIDaemonProcess geonode user=www-data threads=10 processes=1
<VirtualHost *:80>
    ServerName geonode
    ServerAdmin webmaster@localhost

    ErrorLog /var/log/apache2/error.log
    LogLevel warn
    CustomLog /var/log/apache2/access.log combined

    WSGIProcessGroup geonode
    WSGIPassAuthorization On
    WSGIScriptAlias / /usr/lib/python2.7/dist-packages/geonode/wsgi.py

    <Directory "/usr/lib/python2.7/dist-packages/geonode/">
        Order allow,deny
        Options Indexes FollowSymLinks
        IndexOptions FancyIndexing
        Allow from all
        Require all granted
    </Directory>

    Alias /static/ /var/www/geonode/static/
    Alias /uploaded/ /var/www/geonode/uploaded/

    <Proxy *>
      Order allow,deny
      Allow from all
    </Proxy>

    ProxyPreserveHost On
    ProxyPass /geoserver http://localhost:8082/geoserver
    ProxyPassReverse /geoserver http://localhost:8082/geoserver
</VirtualHost>
EOF
echo "Done"

#Create databases
echo "create $GEONODE_DB database with PostGIS"
sudo -u "$USER_NAME" createdb -E UTF8 "$GEONODE_DB"
sudo -u "$USER_NAME" psql "$GEONODE_DB" -c 'CREATE EXTENSION postgis;'
echo "Done"

echo "create $GEONODE_STORE database with PostGIS"
sudo -u "$USER_NAME" createdb -E UTF8 "$GEONODE_STORE"
sudo -u "$USER_NAME" psql "$GEONODE_STORE" -c 'CREATE EXTENSION postgis;'
echo "Done"

echo "Copying settings files"
#Replace local_settings.py
sudo cp -f "$BUILD_DIR/../app-conf/geonode/local_settings.py.sample" \
    "$GEONODE_DIR/local_settings.py"
sudo cp -f "$BUILD_DIR/../app-conf/geonode/sample_admin.json" \
    "$GEONODE_DIR/base/fixtures/sample_admin.json"
sudo cp -f "$BUILD_DIR/../app-conf/geonode/default_oauth_apps.json" \
    "$GEONODE_DIR/base/fixtures/default_oauth_apps.json"
sudo cp -f "$BUILD_DIR/../app-conf/geonode/create_db_store.py" \
    "$GEONODE_DIR/create_db_store.py"

#Change GeoServer port in settings.py
sed -i -e 's|http://localhost:8080/geoserver/|http://localhost:8082/geoserver/|' \
    "$GEONODE_DIR/settings.py"
sed -i -e 's|http://localhost:8000/|http://geonode/|' \
    "$GEONODE_DIR/settings.py"
echo "Done"

# make the static & upload dir
mkdir -p "$STATIC_PATH"
mkdir -p "$UPLOAD_PATH"

echo "Configuring GeoNode"
# Create tables in the database
django-admin makemigrations --noinput --settings=geonode.settings
sudo -u "$USER_NAME" django-admin migrate --noinput --settings=geonode.settings
sudo -u "$USER_NAME" django-admin syncdb --noinput --settings=geonode.settings

# Insert default data
django-admin loaddata "$GEONODE_DIR/base/fixtures/initial_data.json" --settings=geonode.settings

# Install sample admin. Username:admin password:admin
django-admin loaddata "$GEONODE_DIR/base/fixtures/sample_admin.json" --settings=geonode.settings

#TODO: Import oauth settings
#django-admin loaddata "$GEONODE_DIR/base/fixtures/default_oauth_apps.json" --settings=geonode.settings

# Collect static files
django-admin collectstatic --noinput --settings=geonode.settings --verbosity=0
echo "Done"

echo "Stopping GeoServer"
"$GEOSERVER_PATH"/bin/shutdown.sh &> /dev/null &
sleep 30;
echo "Done"

echo "Starting GeoServer to update layers in the geonode db"
"$GEOSERVER_PATH"/bin/startup.sh &> /dev/null &
sleep 90;
echo "Done"

#TODO: Create GeoServer store
#python "$GEONODE_DIR"/create_db_store.py

# run updatelayers
echo "Updating GeoNode layers..."
django-admin updatelayers --settings=geonode.settings --ignore-errors
echo "Done"

echo "Stopping GeoServer"
"$GEOSERVER_PATH"/bin/shutdown.sh &> /dev/null &
sleep 30;
echo "Done"

# GeoServer startup above will create files and directories
# owned by root in the GeoServer directory. Ordinary users must
# have write access to these to be able to start GeoServer.
adduser "$USER_NAME" users
chmod -R g+w "$GEOSERVER_PATH/data_dir"
chmod -R g+w "$GEOSERVER_PATH/logs"
chgrp -R users "$GEOSERVER_PATH/data_dir"
chgrp -R users "$GEOSERVER_PATH/logs"

# Make the apache user the owner of the required dirs.
chown -R www-data:www-data "$STATIC_PATH"
chown -R www-data:www-data "$UPLOAD_PATH"

# Install desktop icon
echo "Installing geonode icon"
cp -f "$BUILD_DIR/../app-conf/geonode/geonode.png" \
       /usr/share/icons/

# Startup/Stop scripts set-up
mkdir -p "$GEONODE_BIN_FOLDER"
chgrp users "$GEONODE_BIN_FOLDER"

if [ ! -e "$GEONODE_BIN_FOLDER/geonode-start.sh" ] ; then
   cat << EOF > "$GEONODE_BIN_FOLDER/geonode-start.sh"
#!/bin/sh

STAT=\`curl -s "http://localhost:8082/geoserver/ows" | grep 8082\`

if [ -z "\$STAT" ] ; then
    $GEOSERVER_PATH/bin/startup.sh &

    DELAY=20
    (
    for TIME in \`seq \$DELAY\` ; do
	sleep 1
	echo "\$TIME \$DELAY" | awk '{print int(0.5+100*\$1/\$2)}'
	done
    ) | zenity --progress --auto-close --text "GeoNode is starting GeoServer ..."
fi

firefox http://geonode/
EOF
fi

if [ ! -e "$GEONODE_BIN_FOLDER/geonode-stop.sh" ] ; then
   cat << EOF > "$GEONODE_BIN_FOLDER/geonode-stop.sh"
#!/bin/sh

$GEOSERVER_PATH/bin/shutdown.sh &

zenity --info --text "GeoNode and GeoServer stopped"
EOF
fi

chmod 755 $GEONODE_BIN_FOLDER/geonode-start.sh
chmod 755 $GEONODE_BIN_FOLDER/geonode-stop.sh

# Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/geonode-admin.desktop ] ; then
    cat << EOF > /usr/local/share/applications/geonode-admin.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Admin GeoNode
Comment=GeoNode Home
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://geonode/
Icon=/usr/share/icons/geonode.png
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/local/share/applications/geonode-admin.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/geonode-admin.desktop"

# Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/geonode-start.desktop ] ; then
    cat << EOF > /usr/local/share/applications/geonode-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start GeoNode
Comment=Starts GeoNode
Categories=Application;Geography;Geoscience;Education;
Exec=$GEONODE_BIN_FOLDER/geonode-start.sh
Icon=/usr/share/icons/geonode.png
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/local/share/applications/geonode-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/geonode-start.desktop"

# Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/geonode-stop.desktop ] ; then
    cat << EOF > /usr/local/share/applications/geonode-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop GeoNode
Comment=Stops GeoNode
Categories=Application;Geography;Geoscience;Education;
Exec=$GEONODE_BIN_FOLDER/geonode-stop.sh
Icon=/usr/share/icons/geonode.png
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/local/share/applications/geonode-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/geonode-stop.desktop"

# # geonode Documentation
# echo "Getting geonode documentation"
# [ -d "$DOC_DIR" ] || mkdir -p "$DOC_DIR"

# cd "$DOC_DIR"
# chmod g+w .
# chgrp users .

# wget -c --progress=dot:mega \
#     "https://media.readthedocs.org/pdf/geonode/latest/geonode.pdf" \
#     -O geonode_documentation-latest.pdf

# ln -sf geonode_documentation-latest.pdf geonode_documentation.pdf
# chmod g+w -R geonode_documentation*
# chgrp users -R geonode_documentation*
# ln -sTf "$DOC_DIR" /var/www/html/geonode-docs

# # Add Documentation Launch icon to desktop
# if [ ! -e /usr/local/share/applications/geonode-docs.desktop ] ; then
#     cat << EOF > /usr/local/share/applications/geonode-docs.desktop
# [Desktop Entry]
# Type=Application
# Encoding=UTF-8
# Name=GeoNode Documentation
# Comment=GeoNode Documentation
# Categories=Application;Geography;Geoscience;Education;
# Exec=evince "$DOC_DIR/geonode_documentation.pdf"
# Icon=/usr/share/icons/geonode.png
# Terminal=false
# StartupNotify=false
# EOF
# fi
# cp -a /usr/local/share/applications/geonode-docs.desktop "$USER_HOME/Desktop/"
# chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geonode-docs.desktop"

#Enable GeoNode and reload apache
a2enmod proxy
a2ensite geonode

# Reload Apache
/etc/init.d/apache2 force-reload

#FIXME: There should be a better way to do this...
cp -f "$BUILD_DIR/../app-conf/geonode/rc.geonode" \
       /etc
chmod u+rx,go-rx /etc/rc.geonode
cp /etc/init.d/rc.local /etc/init.d/rc.geonode
sed -i -e 's/rc\.local/rc.geonode/' /etc/init.d/rc.geonode
ln -s /etc/init.d/rc.geonode /etc/rc2.d/S98rc.geonode
###

apt-add-repository --yes --remove ppa:geonode/osgeo

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
