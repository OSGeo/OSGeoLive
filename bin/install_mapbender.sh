#!/bin/sh
#############################################################################
#
# Purpose: This script will install Mapbender and will create a PostgreSQL database. 
# The script will also add an ALIAS for Mapbender and a Desktop icon.
#
#############################################################################
# Copyright (c) 2009-2023 The Open Source Geospatial Foundation and others.
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

#
# Requires: Apache2, PHP, PostgreSQL
#
# Uninstall:
# ============
# sudo rm -rf /var/www/html/mapbender

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR="/tmp/build_mapbender"
INSTALLURL="https://www.mapbender.org/builds/4.0.2/"
INSTALLFILE="mapbender-starter-v4.0.2"
INSTALL_DIR="/var/www/html"

mkdir -p "$TMP_DIR"

# Install mapbender dependencies.
echo "Installing mapbender dependencies"

apt-get install --assume-yes php php-imagick php-pgsql php-gd php-curl php-cli php-xml php-sqlite3 php-apcu php-intl php-zip php-mbstring php-bz2

a2enmod rewrite

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
    echo "... Mapbender already downloaded"
fi


# uncompress mapbender
tar xfz "$INSTALLFILE.tar.gz"

#rm -rf "$INSTALL_DIR/$INSTALLFILE"
cp -R "$INSTALLFILE" "$INSTALL_DIR/"
mv "$INSTALL_DIR/$INSTALLFILE" "$INSTALL_DIR/mapbender"
chmod -R uga+r "$INSTALL_DIR/mapbender"
chown -R www-data:www-data "$INSTALL_DIR/mapbender"


# create mapbender database
cd "$INSTALL_DIR/mapbender/"


rm  "$INSTALL_DIR/mapbender/.env.local"
cp "$BUILD_DIR"/../app-conf/mapbender/.env.local   "$INSTALL_DIR/mapbender/.env.local"

rm  "$INSTALL_DIR/mapbender/config/packages/doctrine.yaml"
cp "$BUILD_DIR"/../app-conf/mapbender/doctrine.yaml  "$INSTALL_DIR/mapbender/config/packages/doctrine.yaml"

bin/console doctrine:database:create
bin/console doctrine:schema:create
bin/console assets:install public --symlink --relative
bin/console fom:user:resetroot --username="root" --password="root" --email="root@example.com" --silent
bin/console mapbender:database:init -v

chown -R user:www-data "$INSTALL_DIR/mapbender"
chmod -R ug+w "$INSTALL_DIR/mapbender/var/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender/var/log/"
bin/console assets:install public --symlink --relative

chown -R user:www-data "$INSTALL_DIR/mapbender"
chmod -R ug+w "$INSTALL_DIR/mapbender/var/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender/var/log/"
chmod -R ug+w "$INSTALL_DIR/mapbender/config/"
chmod -R ug+w "$INSTALL_DIR/mapbender/public/"

chmod -R ug+w "$INSTALL_DIR/mapbender/var/db/demo.sqlite"

# Create apache2 configuration for mapbender
if [ ! -e /etc/apache2/conf-available/mapbender.conf ] ; then
   cat << EOF > /etc/apache2/conf-available/mapbender.conf
Alias /mapbender /var/www/html/mapbender/public/
<Directory /var/www/html/mapbender/public/>
Options MultiViews FollowSymLinks
DirectoryIndex index.php

Require all granted
RewriteEngine On
RewriteBase /mapbender/
RewriteCond %{ENV:REDIRECT_STATUS} ^$
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php/ [PT,L,QSA] 
</Directory>
EOF
fi

ln -s /etc/apache2/conf-available/mapbender.conf /etc/apache2/conf-enabled/mapbender.conf

# Restart apache2 for mapbender
/etc/init.d/apache2 force-reload

### install desktop icon ##
echo "Installing Mapbender desktop icon"
if [ ! -e "/usr/local/share/icons/mapbender.png" ] ; then
   mkdir -p /usr/local/share/icons
   cp -f "$BUILD_DIR"/../app-conf/mapbender/mapbender.png /usr/local/share/icons/
fi


#Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/mapbender.desktop ] ; then
   mkdir -p /usr/local/share/applications
   cat << EOF > /usr/local/share/applications/mapbender.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapbender
Comment=Mapbender
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/mapbender/
Icon=/usr/local/share/icons/mapbender.png
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/local/share/applications/mapbender.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/mapbender.desktop"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
