#!/bin/sh
#############################################################################
#
# Purpose: This script will install GeoNode
#
#############################################################################
# Copyright (c) 2013-2023 Open Source Geospatial Foundation (OSGeo) and others.
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
GEOSERVER_VERSION="2.21.0"
GEOSERVER_PATH="/usr/local/lib/geoserver-$GEOSERVER_VERSION"
GEONODE_BIN_FOLDER="/usr/local/share/geonode"
GEONODE_DIR="/usr/lib/python3/dist-packages/geonode"
STATIC_PATH="/var/www/geonode/static"
UPLOAD_PATH="/var/www/geonode/uploaded"
# TMP="/tmp/build_geoserver"

# Install packages
# add-apt-repository -y ppa:geonode/osgeolive
add-apt-repository -y ppa:gcpp-kalxas/geonode
apt-get -q update

apt-get install --yes --no-install-recommends python3-geonode libapache2-mod-wsgi-py3 \
        curl python3-gisdata
# apt-get install --yes -o Dpkg::Options::="--force-overwrite" python3-pinax-ratings

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
    WSGIScriptAlias / /usr/lib/python3/dist-packages/geonode/wsgi.py

    <Directory "/usr/lib/python3/dist-packages/geonode/">
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

# Enable local settings in wsgi module
sed -i -e 's|geonode.settings|geonode.local_settings|' \
    "$GEONODE_DIR/wsgi.py"

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
sudo cp -f "$BUILD_DIR/../app-conf/geonode/create_db_store.py" \
    "$GEONODE_DIR/create_db_store.py"

sed -i -e 's|localhost:8080/|localhost:8082/|' \
    "$GEONODE_DIR/base/fixtures/default_oauth_apps.json"

#Change GeoServer port in settings.py
sed -i -e 's|http://localhost:8080/geoserver/|http://localhost:8082/geoserver/|' \
    "$GEONODE_DIR/settings.py"
sed -i -e "s|'SITE_HOST_NAME', 'localhost'|'SITE_HOST_NAME', 'geonode'|" \
    "$GEONODE_DIR/settings.py"
sed -i -e "s|'SITE_HOST_PORT', 8000|'SITE_HOST_PORT', 80|" \
    "$GEONODE_DIR/settings.py"
echo "Done"

# Patch monitoring to not use user_agents:
# (https://github.com/GeoNode/geonode/issues/6703#issuecomment-757387363)
# sed -i -e "s/import user_agents/#import user_agents/" \
#         "$GEONODE_DIR/monitoring/models.py"

# make the static & upload dir
mkdir -p "$STATIC_PATH"
mkdir -p "$UPLOAD_PATH"

echo "Configuring GeoNode"
# Create tables in the database
django-admin makemigrations --noinput --settings=geonode.local_settings
sudo -u "$USER_NAME" django-admin migrate --noinput --settings=geonode.local_settings

# Install sample admin. Username:admin password:admin
django-admin loaddata "$GEONODE_DIR/people/fixtures/sample_admin.json" --settings=geonode.local_settings

# Import oauth settings
django-admin loaddata "$GEONODE_DIR/base/fixtures/default_oauth_apps.json" --settings=geonode.local_settings

# Insert default data
django-admin loaddata "$GEONODE_DIR/base/fixtures/initial_data.json" --settings=geonode.local_settings

# Collect static files
django-admin collectstatic --noinput --settings=geonode.local_settings --verbosity=0
echo "Done"

echo "Stopping GeoServer"
"$GEOSERVER_PATH"/bin/shutdown.sh &> /dev/null &
sleep 30;
echo "Done"

# # Setup GeoServer oauth
# echo "Starting GeoServer oauth2 configuration"
# mkdir -p "$TMP"
# cd "$TMP"

# # Download and install geonode-geoserver extension
# echo "Downloading geonode-geoserver extension"
# wget --progress=dot:mega \
#   -O "geonode-geoserver-ext-web-app-$GEOSERVER_VERSION-geoserver-plugin.zip" \
#   "https://download.osgeo.org/livedvd/data/geoserver/geonode-geoserver-ext-web-app-$GEOSERVER_VERSION-geoserver-plugin.zip"
# ## Cached version of
# # "https://build.geo-solutions.it/geonode/geoserver/latest/"
# echo "Installing geonode-geoserver extension"
# unzip -o -q "geonode-geoserver-ext-web-app-$GEOSERVER_VERSION-geoserver-plugin.zip" -d "$GEOSERVER_PATH/webapps/geoserver/WEB-INF/lib"

# # Download and install geoserver data folder
# echo "Downloading geoserver data folder"
# wget --progress=dot:mega \
#   -O "data-$GEOSERVER_VERSION-osgeolive.zip" \
#   "https://download.osgeo.org/livedvd/data/geoserver/data-$GEOSERVER_VERSION-osgeolive.zip"
# ## Cached version of
# # "https://build.geo-solutions.it/geonode/geoserver/latest/"
# echo "Installing geoserver data folder"
# unzip -o -q "data-$GEOSERVER_VERSION-osgeolive.zip"
# rm -rf "$GEOSERVER_PATH"/data_dir
# mv data_osgeolive "$GEOSERVER_PATH"/data_dir
# chown -R root:users "$GEOSERVER_PATH"/data_dir
# find "$GEOSERVER_PATH"/data_dir -type d -exec chmod 775 {} \;

# # Adding GeoFence path to GeoServer startup.sh
# sed -i -e '$ d' "$GEOSERVER_PATH"/bin/startup.sh
# cat << EOF >> "$GEOSERVER_PATH/bin/startup.sh"
# exec "\$_RUNJAVA" \$JAVA_OPTS \$MARLIN_ENABLER -DGEOSERVER_DATA_DIR="\$GEOSERVER_DATA_DIR" -Dgeofence.dir="\$GEOSERVER_DATA_DIR/geofence" -Djava.awt.headless=true -DSTOP.PORT=8079 -DSTOP_KEY=geoserver -jar start.jar
# EOF

# Fix geonode path in oauth settings
sed -i -e "s|http://localhost:8080|http://localhost:8082|g" "$GEOSERVER_PATH"/data_dir/security/filter/geonode-oauth2/config.xml

sed -i -e "s|http://localhost:8000|http://geonode|g" "$GEOSERVER_PATH"/data_dir/security/filter/geonode-oauth2/config.xml

sed -i -e "s|http://localhost:8000|http://geonode|g" "$GEOSERVER_PATH"/data_dir/security/role/geonode\ REST\ role\ service/config.xml

sed -i -e "s|http://localhost:8080|http://localhost:8082|g" "$GEOSERVER_PATH"/data_dir/global.xml

# cd "$BUILD_DIR"
# echo "Done"

echo "Starting GeoServer to update layers in the geonode db"
"$GEOSERVER_PATH"/bin/startup.sh &> /dev/null &
sleep 120;
echo "Done"

#TODO: Create GeoServer store
python3 "$GEONODE_DIR"/create_db_store.py

# run updatelayers
echo "Updating GeoNode layers..."
django-admin updatelayers --settings=geonode.local_settings --ignore-errors
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

# Add geonode in hosts file
cp -f "$BUILD_DIR/../app-conf/geonode/rc.geonode" \
       /etc/
chmod u+rx,go-rx /etc/rc.geonode

if [ ! -e /etc/systemd/system/geonode_hosts.service ] ; then
    cat << EOF > /etc/systemd/system/geonode_hosts.service
[Unit]
Description=Add geonode to hosts file

[Service]
ExecStart=/bin/sh /etc/rc.geonode
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
fi

## reload systemctl config
systemctl daemon-reload

## Start service to add user to groups
systemctl start geonode_hosts.service

## Enable geonode_hosts service at startup
systemctl enable geonode_hosts.service

# apt-add-repository --yes --remove ppa:geonode/osgeolive
apt-add-repository --yes --remove ppa:gcpp-kalxas/geonode

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
