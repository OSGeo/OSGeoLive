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
PARAMETERSINSTALLURL="https://www.mapbender.org/builds/osgeolive"
INSTALLURL="http://www.mapbender.org/builds/3.3.3"
INSTALLFILE="mapbender-starter-v3.3.3"
PARAMETERSFILE="mapbender-starter-3.3.0"
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
if [ ! -f "${INSTALLFILE}_parameters.yml" ] ; then 
   wget -O ${PARAMETERSFILE}_parameters.yml --progress=dot:mega \
      "$PARAMETERSINSTALLURL/${PARAMETERSFILE}_parameters.yml"
else
    echo "... Mapbender yml already downloaded"
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
#cp "$TMP_DIR/${INSTALLFILE}_parameters.yml"    "$INSTALL_DIR/mapbender/app/config/parameters.yml"
rm  "$INSTALL_DIR/mapbender/app/config/parameters.yml"
cp "$TMP_DIR/${PARAMETERSFILE}_parameters.yml"    "$INSTALL_DIR/mapbender/app/config/parameters.yml"

sed -i -e 's/3.3.0/3.3.3/g' "$INSTALL_DIR/mapbender/app/config/parameters.yml"

app/console doctrine:database:create
app/console doctrine:schema:create
app/console init:acl
app/console assets:install web --symlink --relative
app/console fom:user:resetroot --username="root" --password="root" --email="root@example.com" --silent
app/console mapbender:database:init
app/console mapbender:application:import app/config/applications

chown -R user:www-data "$INSTALL_DIR/mapbender"
chmod -R ug+w "$INSTALL_DIR/mapbender/app/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender/app/logs/"
app/console assets:install web --symlink --relative

chown -R user:www-data "$INSTALL_DIR/mapbender"
chmod -R ug+w "$INSTALL_DIR/mapbender/app/cache/"
chmod -R ug+w "$INSTALL_DIR/mapbender/app/logs/"
chmod -R ug+w "$INSTALL_DIR/mapbender/app/config/"
chmod -R ug+w "$INSTALL_DIR/mapbender/web/"

chmod -R ug+w "$INSTALL_DIR/mapbender/app/db/demo.sqlite"

#Create apache2 configuration for mapbender
#FIXME: make cleaner like
# cat << EOF > /etc/apache2/conf-available/mapbender
#content
#content
#content
#EOF
echo "#Configure apache for mapbender " > /etc/apache2/conf-available/mapbender.conf
echo "Alias /mapbender $INSTALL_DIR/mapbender/web/" >> \
   /etc/apache2/conf-available/mapbender.conf
echo "<Directory $INSTALL_DIR/mapbender/web/>" >> /etc/apache2/conf-available/mapbender.conf
echo "Options MultiViews FollowSymLinks" >> /etc/apache2/conf-available/mapbender.conf
echo "DirectoryIndex app.php" >> /etc/apache2/conf-available/mapbender.conf
echo "Require all granted" >> /etc/apache2/conf-available/mapbender.conf

echo "RewriteEngine On" >> /etc/apache2/conf-available/mapbender.conf
echo "RewriteBase /mapbender/" >> /etc/apache2/conf-available/mapbender.conf
echo "RewriteCond %{ENV:REDIRECT_STATUS} ^$" >> /etc/apache2/conf-available/mapbender.conf
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> /etc/apache2/conf-available/mapbender.conf
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> /etc/apache2/conf-available/mapbender.conf
echo "RewriteRule ^(.*)$ app.php/$1 [PT,L,QSA]" >> /etc/apache2/conf-available/mapbender.conf
echo "</Directory>" >> /etc/apache2/conf-available/mapbender.conf       

ln -s /etc/apache2/conf-available/mapbender.conf /etc/apache2/conf-enabled/mapbender.conf

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
Icon=/usr/local/share/icons/mapbender3_desktop_48x48.png
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/local/share/applications/mapbender.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/mapbender.desktop"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
