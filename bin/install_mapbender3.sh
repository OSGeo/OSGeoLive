#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install mapbender3 and will create a PostgreSQL database
#  mapbender3.0.3.0. 
# The script will also add an ALIAS for Mapbender3 and a Desktop icon.
#
# Requires: Apache2, PHP5, PostgreSQL
#
# Uninstall:
# ============
# sudo rm -rf /var/www/mapbender3

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR="/tmp/build_mapbender3"
PARAMETERSINSTALLURL="http://mapbender3.org/builds/"
INSTALLURL="http://mapbender3.org/builds/"
INSTALLFILE="mapbender3-3.0.3.1"
PARAMETERSFILE="mapbender3-3.0.3.1"
INSTALL_DIR="/var/www"

mkdir -p "$TMP_DIR"

# Install mapbender dependencies.
echo "Installing mapbender"

apt-get install --assume-yes php5 php5-imagick php5-pgsql php5-gd \
  php5-curl php5-cli php5-sqlite sqlite php-apc php5-intl

if [ ! -x "`which wget`" ] ; then
    apt-get --assume-yes install wget
fi

if [ ! -x "`which unzip`" ] ; then
    apt-get --assume-yes install unzip
fi


# download and unzip sources...

cd "$TMP_DIR"
if [ ! -f "$INSTALLFILE.tar.gz" ] ; then 
   wget -O $INSTALLFILE.tar.gz --progress=dot:mega \
      "$INSTALLURL/$INSTALLFILE.tar.gz"
else
    echo "... Mapbender3 already downloaded"
fi
if [ ! -f "${INSTALLFILE}_parameters.yml" ] ; then 
   wget -O ${INSTALLFILE}_parameters.yml --progress=dot:mega \
      "$PARAMETERSINSTALLURL/${PARAMETERSFILE}_parameters.yml"
else
    echo "... Mapbender3 yml already downloaded"
fi

# uncompress mapbender
tar xfz "$INSTALLFILE.tar.gz"
#rm -rf "$INSTALL_DIR/$INSTALLFILE"
cp -R "$INSTALLFILE" "$INSTALL_DIR/"
mv "$INSTALL_DIR/$INSTALLFILE" "$INSTALL_DIR/mapbender3"
chmod -R uga+r "$INSTALL_DIR/mapbender3"
chown -R www-data:www-data "$INSTALL_DIR/mapbender3"


# create mapbender database
cd "$INSTALL_DIR/mapbender3/"
#cp "$TMP_DIR/${INSTALLFILE}_parameters.yml"    "$INSTALL_DIR/mapbender3/app/config/parameters.yml"

cp "$TMP_DIR/${PARAMETERSFILE}_parameters.yml"    "$INSTALL_DIR/mapbender3/app/config/parameters.yml"

app/console doctrine:database:create
app/console doctrine:schema:create
app/console init:acl
app/console assets:install web
app/console fom:user:resetroot --username="root" --password="root" --email="root@example.com" --silent
app/console doctrine:fixtures:load --fixtures=./mapbender/src/Mapbender/CoreBundle/DataFixtures/ORM/Epsg/ --append
app/console doctrine:fixtures:load --fixtures=./mapbender/src/Mapbender/CoreBundle/DataFixtures/ORM/Application/ --append

chown -R www-data:www-data "$INSTALL_DIR/mapbender3"
chmod -R ug+w "$INSTALL_DIR/mapbender3/app/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender3/app/logs/"
app/console assets:install web

chown -R www-data:www-data "$INSTALL_DIR/mapbender3"
chmod -R ug+w "$INSTALL_DIR/mapbender3/app/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender3/app/logs/"
chmod -R ug+w "$INSTALL_DIR/mapbender3/web/"

#Create apache2 configuration for mapbender
#FIXME: make cleaner like
# cat << EOF > /etc/apache2/conf.d/mapbender3
#content
#content
#content
#EOF
echo "#Configure apache for mapbender3 " > /etc/apache2/conf.d/mapbender3
echo "Alias /mapbender3 $INSTALL_DIR/mapbender3/web/" >> \
   /etc/apache2/conf.d/mapbender3
echo "<Directory $INSTALL_DIR/mapbender3/web>" >> /etc/apache2/conf.d/mapbender3
echo "Options MultiViews" >> /etc/apache2/conf.d/mapbender3
echo "DirectoryIndex app_dev.php" >> /etc/apache2/conf.d/mapbender3
echo "Order allow,deny" >> /etc/apache2/conf.d/mapbender3
echo "Allow from all" >> /etc/apache2/conf.d/mapbender3
echo "</Directory>" >> /etc/apache2/conf.d/mapbender3       


#Restart apache2 for mapbender
/etc/init.d/apache2 force-reload

### install desktop icon ##
echo "Installing Mapbender desktop icon"
if [ ! -e "/usr/local/share/icons/mapbender3_desktop_48x48.png" ] ; then
   wget -nv -N "https://svn.osgeo.org/mapbender/trunk/build/osgeolive/mapbender3_desktop_48x48.png"
   mkdir -p /usr/local/share/icons
   cp -f mapbender3_desktop_48x48.png /usr/local/share/icons/
fi


#Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/mapbender3.desktop ] ; then
   mkdir -p /usr/local/share/applications
   cat << EOF > /usr/local/share/applications/mapbender3.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapbender3
Comment=Mapbender
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/mapbender3/app_dev.php
Icon=/usr/local/share/icons/mapbender3_desktop_48x48.png
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/local/share/applications/mapbender3.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/mapbender3.desktop"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
