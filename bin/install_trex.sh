#!/bin/sh
#############################################################################
#
# Purpose: This script will install t-rex Vector Tile Server
#           homepage   http://t-rex.tileserver.ch/
#
#############################################################################
# Author: Brian M Hamlin <darkblue_b> / Pirmin Kalberer <pka@sourcepole.com>
# Copyright (c) 2018-2022 The Open Source Geospatial Foundation and others.
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
BUILD_DIR='/tmp/build_t-rex'
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo "\nCreating temporary directory $BUILD_DIR..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
echo "\nDownloading t-rex package..."
wget -c --tries=3 --progress=dot:mega -O t-rex_0.14.3-1.jammy_amd64.deb \
   "https://github.com/t-rex-tileserver/t-rex/releases/download/v0.14.3/t-rex_0.14.3-1.jammy_amd64.deb"

echo "\nInstalling t-rex..."
dpkg -i t-rex_0.14.3-1.jammy_amd64.deb

echo "\nGenerating launcher..."
wget -O /usr/share/pixmaps/t-rex.png 'https://avatars2.githubusercontent.com/u/31633660?s=200&v=4'

## TODO create a demo config

if [ ! -e /usr/share/applications/t-rex.desktop ] ; then
   cat << EOF > /usr/share/applications/t-rex.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=T-Rex
Comment=Vector Tile Server
Categories=Application;Internet;
Exec=t_rex serve --dbconn postgresql://user:user@localhost/osm_local --simplify false
Icon=t-rex
Terminal=true
StartupNotify=false
EOF
fi
cp /usr/share/applications/t-rex.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/t-rex.desktop"

## Cleanup
echo "\nCleanup..."
cd "$BASE_DIR"
rm -rf "$BUILD_DIR"
## TODO cleanup
#rm -rf dirs files

####
./diskspace_probe.sh "`basename $0`" end
