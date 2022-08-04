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
# This script will install pg_tileserv server

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_pg_tileserv"
BIN="/usr/local/bin"

apt-get install --yes golang-go

mkdir -p "$TMP"
cd "$TMP"

wget -c --progress=dot:mega \
   -O pg_tileserv_latest_linux.zip \
   "https://postgisftw.s3.amazonaws.com/pg_tileserv_latest_linux.zip"

unzip -o -q pg_tileserv_latest_linux.zip
chmod 755 pg_tileserv
mv pg_tileserv "$BIN"

mkdir "$BUILD_DIR"/../app-conf/pg_tileserv
chown -R "$USER_NAME":"$USER_NAME" *
cp config/pg_tileserv.toml.example config/pg_tileserv.toml
mv * "$BUILD_DIR"/../app-conf/pg_tileserv

wget -q -O /usr/share/icons/pg_tileserv.png \
   "https://raw.githubusercontent.com/CrunchyData/pg_tileserv/master/hugo/static/crunchy-spatial-logo.png"

cat << EOF > "/usr/share/applications/pg_tileserv.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=pg_tileserv
Comment=pg_tileserv
Categories=Application;Geography;Geoscience;Education;
Exec=firefox "http://localhost:7800/"
Icon=/usr/share/icons/pg_tileserv.png
Terminal=false
EOF

cp -a /usr/share/applications/pg_tileserv.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/pg_tileserv.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
