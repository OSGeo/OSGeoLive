#!/bin/sh
# Copyright (c) 2020 The Open Source Geospatial Foundation and others.
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
# This script will install Tegola server

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_tegola"
BIN="/usr/local/bin"
TEGOLA_VERSION="v0.12.1"

apt-get install --yes golang-go

mkdir -p "$TMP"
cd "$TMP"

wget -c --progress=dot:mega \
   -O tegola_linux_amd64.zip \
   "https://github.com/go-spatial/tegola/releases/download/$TEGOLA_VERSION/tegola_linux_amd64.zip"

unzip -o -q tegola_linux_amd64.zip
chmod 755 tegola
mv tegola "$BIN"

cd "$USER_HOME"
cp "$BUILD_DIR"/../app-conf/tegola/config.toml "$BIN"
mkdir -p /var/www/html/tegola/js
cp "$BUILD_DIR"/../app-conf/tegola/open-layers-example.html /var/www/html/tegola/index.html
cp "$BUILD_DIR"/../app-conf/tegola/style.js /var/www/html/tegola/js/style.js

wget -q -O /usr/share/icons/tegola.png "https://github.com/go-spatial/tegola-docs/raw/master/static/images/logo.png"

cat << EOF > "/usr/share/applications/tegola.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Tegola Demo
Comment=Tegola
Categories=Application;Geography;Geoscience;Education;
Exec=firefox "http://localhost/tegola/"
Icon=/usr/share/icons/tegola.png
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/tegola.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/tegola.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
