#!/bin/sh
#############################################################################
#
# Purpose: This script will install t-rex Vector Tile Server
#           homepage   http://t-rex.tileserver.ch/
#
#############################################################################
# Author: Brian M Hamlin <darkblue_b> / Pirmin Kalberer <email>
# Copyright (c) 2018 The Open Source Geospatial Foundation and others.
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

## make a tmp dir to download t-rex

BASE_DIR=`pwd`
BUILD_DIR='/tmp/build_trex'
#WEB_DIR=trex
#UNZIP_DIR="$BUILD_DIR/$WEB_DIR"
TREX_VERSION="0.9.0"
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo "\nCreating temporary directory $BUILD_DIR..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
echo "\nDownloading trex package..."
wget -c --tries=3 --progress=dot:mega \
   "http://download.osgeo.org/livedvd/12/t_rex/t-rex-v${TREX_VERSION}-x86_64-unknown-linux-gnu.deb"

echo "\nInstalling trex..."
dpkg -i t-rex-v${TREX_VERSION}-x86_64-unknown-linux-gnu.deb


echo "\nGenerating launcher..."
#cp TREX_Logo.png /usr/share/pixmaps/

if [ ! -e /usr/share/applications/trex.desktop ] ; then
   cat << EOF > /usr/share/applications/trex.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=T-Rex
Comment=T-Rex Examples
Categories=Application;Internet;
Exec=firefox http://localhost/trex/ http://localhost/trex/Apps/HelloWorld.html http://localhost/osgeolive/en/quickstart/trex_quickstart.html
Icon=trex
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/trex.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/trex.desktop"

## Cleanup
echo "\nCleanup..."
cd "$BASE_DIR"
rm -rf "$BUILD_DIR"
## TODO cleanup
#rm -rf dirs files

####
"$BIN_DIR"/diskspace_probe.sh "`basename $0`" end
