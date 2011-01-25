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
# This script will install qgis_mapserver in xubuntu

# Running:
# =======
# sudo ./install_qgis_mapserver.sh

TMP="/tmp/build_qgis_mapserver"
BUILD_DIR=`pwd`
APP_DATA_DIR="$BUILD_DIR/../app-data/qgis-mapserver"
INSTALL_FOLDER="/usr/local"
DATA_FOLDER="/usr/local/share"
PKG_DATA=$DATA_FOLDER/qgis_mapserver
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

## get qgis_mapserver
apt-get install --assume-yes qgis-mapserver libapache2-mod-fcgid

#CGI for testing
ln -s qgis_mapserv.fcgi /usr/lib/cgi-bin/qgis_mapserv

#Sample project
ln -s /usr/local/share/qgis/QGIS-Itasca-Example.qgs /usr/lib/cgi-bin/

#Unpack demo viewer
mkdir -p $PKG_DATA
cd $PKG_DATA
cp "$APP_DATA_DIR/mapviewer.html" .
tar xzf "$APP_DATA_DIR/mapfish-client-libs.tgz"

# Create Desktop Shortcut for Demo viewer
cat << EOF > /usr/share/applications/qgis-mapserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=QGIS Mapserver
Comment=QGIS Mapserver
Categories=Application;Geography;Geoscience;Education;
Exec=firefox $PKG_DATA/mapviewer.html
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/qgis-mapserver.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/qgis-mapserver.desktop"
