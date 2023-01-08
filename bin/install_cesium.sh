#!/bin/sh
#############################################################################
#
# Purpose: This script will install Cesium, homepage http://cesiumjs.org/
#
#############################################################################
# Author: Balasubramaniam Natarajan <bala150985 gmail> / Brian M Hamlin <dbb>
# Copyright (c) 2014-2023 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#############################################################################

./diskspace_probe.sh "`basename $0`" begin

## make a tmp dir to download Cesium,
##  remember the subdir name, use as the local URL
BIN_DIR=`pwd`
BUILD_DIR='/tmp/build_cesium'
WEB_DIR=cesium
UNZIP_DIR="$BUILD_DIR/$WEB_DIR"
CESIUM_VERSION="1.101"
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo "\nCreating temporary directory $BUILD_DIR..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
echo "\nDownloading Cesium..."
wget -c --tries=3 --progress=dot:mega \
   "https://github.com/CesiumGS/cesium/releases/download/${CESIUM_VERSION}/Cesium-${CESIUM_VERSION}.zip"

echo "\nInstalling Cesium..."
IsUnZipPresent=`/usr/bin/which unzip | /usr/bin/wc -l`
if [ $IsUnZipPresent -eq 0 ]; then
  apt-get install --assume-yes unzip
fi

if [ -d "$UNZIP_DIR" ]; then
  rm -rf "$UNZIP_DIR"
fi

mkdir -p "$UNZIP_DIR"
unzip -q "${BUILD_DIR}/Cesium-${CESIUM_VERSION}.zip" -d "$UNZIP_DIR"/

if [ -d /var/www/html/cesium ]; then
  rm -rf /var/www/html/cesium
fi

cp -rf $UNZIP_DIR /var/www/html/
chgrp www-data -R /var/www/html/"$WEB_DIR"
chmod -R 755 /var/www/html/"$WEB_DIR"/Build

echo "\nGenerating launcher..."
cp /var/www/html/cesium/Build/Documentation/Images/CesiumLogo.png /usr/share/pixmaps/cesium.png

if [ ! -e /usr/share/applications/cesium.desktop ] ; then
   cat << EOF > /usr/share/applications/cesium.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Cesium
Comment=Cesium Examples
Categories=Application;Internet;
Exec=firefox http://localhost/cesium/ http://localhost/cesium/Apps/HelloWorld.html http://localhost/osgeolive/en/quickstart/cesium_quickstart.html
Icon=cesium
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/cesium.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/cesium.desktop"

## Cleanup
echo "\nCleanup..."
cd "$BIN_DIR"
rm -rf "$BUILD_DIR"
## TODO are all the files in $UNZIP_DIR needed? The total size is 98MB, can we save a bit here?
#rm -rf /var/www/html/cesium/Build

####
"$BIN_DIR"/diskspace_probe.sh "`basename $0`" end
