#!/bin/sh
#############################################################################
#
# Purpose: This script will install qgis-server in ubuntu
#
#############################################################################
# Copyright (c) 2009-2020 The Open Source Geospatial Foundation and others.
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


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_qgis_server"
APP_DATA_DIR="$BUILD_DIR/../app-data/qgis-server"
APP_CONF_DIR="$BUILD_DIR/../app-conf/qgis-server"
QS_APACHE_CONF_FILE="qgis-fcgid.conf"
DEST_DIR="/var/www/html/qgis_server"

# install qgis-server
apt-get install --assume-yes qgis-server libapache2-mod-fcgid

# Make sure Apache has cgi-bin setup, and that fcgid is enabled
a2enmod cgi
a2enmod fcgid

# Add Apache config to limit max FCGI processes
cp $APP_CONF_DIR/$QS_APACHE_CONF_FILE /etc/apache2/conf-available/
a2enconf $QS_APACHE_CONF_FILE

# Sample QGIS project
ln -s /usr/local/share/qgis/QGIS-Itasca-Example.qgz /usr/lib/cgi-bin/

mkdir -p "$TMP"
cd "$TMP"
wget -c --progress=dot:mega "https://github.com/qgis/qwc2-demo-app/releases/download/ci-latest-master/qwc2-demo-app.zip"
unzip -q qwc2-demo-app.zip

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"
mv $TMP/prod/* .
cp "$APP_DATA_DIR/config.json" .
cp "$APP_DATA_DIR/themes.json" .

# Create Desktop Shortcut for Demo viewer
cat << EOF > /usr/share/applications/qgis-server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=QGIS Server
Comment=QGIS Server
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/qgis_server
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/qgis-server.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/qgis-server.desktop"

# Reload Apache
service apache2 --full-restart

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
