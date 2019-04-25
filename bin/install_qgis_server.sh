#!/bin/sh
#############################################################################
#
# Purpose: This script will install qgis_mapserver in ubuntu
#
#############################################################################
# Copyright (c) 2009-2019 The Open Source Geospatial Foundation and others.
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

TMP="/tmp/build_qgis_mapserver"
APP_DATA_DIR="$BUILD_DIR/../app-data/qgis-mapserver"
INSTALL_FOLDER="/usr/local"
DATA_FOLDER="/usr/local/share"
PKG_DATA="$DATA_FOLDER/qgis_mapserver"

APP_CONF_DIR="$BUILD_DIR/../app-conf/qgis-mapserver/"
QS_APACHE_CONF_FILE="qgis-fcgid.conf"
QS_APACHE_CONF=$APP_CONF_DIR$QS_APACHE_CONF_FILE
APACHE_CONF_DIR="/etc/apache2/conf-available/"

## get qgis_mapserver
apt-get install --assume-yes qgis-server libapache2-mod-fcgid

# Make sure Apache has cgi-bin setup, and that fcgid is enabled
a2enmod cgi
a2enmod fcgid

#CGI for testing
# NOTE: this is unnecessary (unused) until there is a virtual host set up;
#       currently, the .fcgi extension is needed to spawn FCGI binary
ln -s qgis_mapserv.fcgi /usr/lib/cgi-bin/qgis_mapserv

# Add Apache config to limit max FCGI processes
cp $QS_APACHE_CONF $APACHE_CONF_DIR
a2enconf $QS_APACHE_CONF_FILE

#Sample project
ln -s /usr/local/share/qgis/QGIS-Itasca-Example.qgs /usr/lib/cgi-bin/

#Unpack demo viewer
mkdir -p "$PKG_DATA"
cd "$PKG_DATA"
cp "$APP_DATA_DIR/mapviewer.html" .
tar xzf "$APP_DATA_DIR/mapfish-client-libs.tgz" --no-same-owner

# Create Desktop Shortcut for Demo viewer
cat << EOF > /usr/share/applications/qgis-mapserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=QGIS Server
Comment=QGIS Server
Categories=Application;Geography;Geoscience;Education;
Exec=firefox $PKG_DATA/mapviewer.html
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/qgis-mapserver.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/qgis-mapserver.desktop"

# Reload Apache
service apache2 --full-restart

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
