#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
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


# About:
# =====
# This script will install mapbender and will create a database mapbender in PostgreSQL with PostGIS. 
# The script will also add an ALIAS for Mapbender and an ALIAS for Mapbender owsproxy

# Running:
# =======
# sudo ./install_mapbender.sh

# Requires: Apache2, PHP5, postgresql/postgis
#
# Uninstall:
# ============
# sudo rm -rf /var/www/mapbender

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_mapbender"
INSTALLURL="http://www.mapbender.org/download/"
INSTALLFILE="mapbender2.7_osgeolive4.5"
INSTALL_DIR="/var/www"
MAPBENDER_DATABASE_NAME="mapbender" 
MAPBENDER_DATABASE_TEMPLATE="template_postgis"
MAPBENDER_DATABASE_USER="user"

mkdir -p "$TMP_DIR"

# Install mapbender dependencies.
echo "Installing mapbender"

apt-get install --assume-yes php5 php5-imagick php5-pgsql php5-gd

sed -i -e 's/short_open_tag = On/short_open_tag = Off/' /etc/php5/apache2/php.ini

if [ ! -x "`which wget`" ] ; then
    apt-get --assume-yes install wget
fi

if [ ! -x "`which gettext`" ] ; then
    apt-get --assume-yes install gettext
fi

if [ ! -x "`which unzip`" ] ; then
    apt-get --assume-yes install unzip
fi

if [ ! -x "`which etherape`" ] ; then
    apt-get --assume-yes install etherape
fi

if [ ! -x "`which pgadmin3`" ] ; then
    apt-get --assume-yes install pgadmin3
fi

# check more libraries...


# download and unzip sources...

cd "$TMP_DIR"
if [ ! -f "$INSTALLFILE.zip" ] ; then 
   wget -O $INSTALLFILE.zip --progress=dot:mega \
      "$INSTALLURL""$INSTALLFILE".zip
else
    echo "... Mapbender already downloaded"
fi

# uncompress mapbender
unzip -q -o $INSTALLFILE.zip
rm -rf $INSTALL_DIR/mapbender
cp -R $INSTALLFILE $INSTALL_DIR/mapbender
chmod -R uga+r $INSTALL_DIR/mapbender
chown -R www-data:www-data $INSTALL_DIR/mapbender
chown -R user $INSTALL_DIR/mapbender/resources
chown -R user $INSTALL_DIR/mapbender/tools



# create mapbender database 

cd $INSTALL_DIR/mapbender/resources/db
chmod +x install_2.7_osgeolive.sh 
sudo -u $USER_NAME ./install_2.7_osgeolive.sh localhost 5432 \
   $MAPBENDER_DATABASE_NAME $MAPBENDER_DATABASE_TEMPLATE $MAPBENDER_DATABASE_USER
chown -R www-data:www-data $INSTALL_DIR/mapbender/resources
chown -R www-data:www-data $INSTALL_DIR/mapbender/tools

#Create apache2 configuration for mapbender
echo "#Configure apache for mapbender " > /etc/apache2/conf.d/mapbender
echo "Alias /mapbender $INSTALL_DIR/mapbender/http/" >> /etc/apache2/conf.d/mapbender
echo "<Directory $INSTALL_DIR/mapbender/http>" >> /etc/apache2/conf.d/mapbender
echo "Options MultiViews" >> /etc/apache2/conf.d/mapbender
echo "DirectoryIndex index.php" >> /etc/apache2/conf.d/mapbender
echo "Order allow,deny" >> /etc/apache2/conf.d/mapbender
echo "Allow from all" >> /etc/apache2/conf.d/mapbender 
echo "</Directory>" >> /etc/apache2/conf.d/mapbender       

#Create apache2 configuration for mapbender-owsproxy
echo "#Configure apache for mapbender-owsproxy " >> /etc/apache2/conf.d/mapbender
echo "Alias /owsproxy $INSTALL_DIR/mapbender/owsproxy/" >> /etc/apache2/conf.d/mapbender
echo "<Directory $INSTALL_DIR/mapbender/owsproxy>" >> /etc/apache2/conf.d/mapbender
echo "Options MultiViews" >> /etc/apache2/conf.d/mapbender
echo "DirectoryIndex index.php" >> /etc/apache2/conf.d/mapbender
echo "Order allow,deny" >> /etc/apache2/conf.d/mapbender
echo "Allow from all" >> /etc/apache2/conf.d/mapbender 
echo "</Directory>" >> /etc/apache2/conf.d/mapbender   

echo "RedirectMatch ^.*owsproxy.([^i][\w\d]+)\/([\w\d]+)\/?$ http://localhost/owsproxy/http/index.php?sid=\$1\&wms=\$2\&" >> /etc/apache2/conf.d/mapbender


#Restart apache2 for mapbender
/etc/init.d/apache2 force-reload

### install desktop icon ##
echo "Installing Mapbender desktop icon"
if [ ! -e "/usr/share/icons/mapbender_desktop_48x48.png" ] ; then
   wget -nv -N "https://svn.osgeo.org/mapbender/trunk/build/osgeolive/mapbender_desktop_48x48.png"
   \cp mapbender_desktop_48x48.png /usr/share/icons/
fi


#Add Launch icon to desktop
if [ ! -e /usr/share/applications/mapbender.desktop ] ; then
   cat << EOF > /usr/share/applications/mapbender.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapbender
Comment=Mapbender
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/mapbender/
Icon=/usr/share/icons/mapbender_desktop_48x48.png
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/mapbender.desktop "$USER_HOME/Desktop/"


echo "Done installing Mapbender"
