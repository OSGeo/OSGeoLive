#!/bin/sh
#
# Copyright (c) 2009-2012 The Open Source Geospatial Foundation.
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
# This script will install geomoose
#
# Requires: Apache2, PHP5, MapServer

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


apt-get --assume-yes install php5-sqlite

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p /tmp/build-geomoose

cd /tmp/build-geomoose

## Download and extract GeoMOOSE 2.8.0
wget -c --progress=dot:mega \
   "http://www.geomoose.org/downloads/geomoose-2.8.0.tar.gz"

tar -xzf geomoose-2.8.0.tar.gz

rm -rf /usr/local/geomoose

mkdir -p /usr/local/geomoose

cd /usr/local/geomoose

mv /tmp/build-geomoose/geomoose*/* .

## Setup htdocs directory to be available to apache
ln -s /usr/local/geomoose/htdocs /var/www/html/geomoose

## Configure GeoMOOSE 2.8.0
cat > /usr/local/geomoose/conf/local_settings.ini <<'EOF'
[paths]
root=/usr/local/geomoose/maps/
mapserver_url=/cgi-bin/mapserv
temp=/tmp/
EOF

cat > /usr/local/geomoose/maps/temp_directory.map <<'EOF'
# This file is used to configure temporary directories for Mapserver Mapfile

IMAGEPATH "/tmp/"

# Remove the "#" before the next "IMAGEPATH" statement if you are using MS4W
# IMAGEPATH "/ms4w/tmp/ms_tmp/"
EOF

## Install icon
base64 -d > /usr/share/icons/geomoose.png <<'EOF'
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAAAXNSR0IArs4c6QAAADZQTFRFAAAA
bL1FbL1Gbb1Ebb1FbL5FbL5Gbb5Ebb5Fbb5Gbr5Fbr5GbL9Gbb9Ebb9Fbb9Gbr9Fbr9GOFtz2wAA
AAF0Uk5TAEDm2GYAAAABYktHRACIBR1IAAAAyklEQVRIx+2TwRKCMAxEV03oFgTx/3/WQy1QTKjo
jOOBXNpJ92WbTAt8HWGnnrTTnl7Iu5FuSdeAvZN3AQDh5TQ6gCZgZaMKkOIY0OichNoWCRASwKVM
8+YDT5s4lT9v9Zwi20xJVIBumDW+HADQaYZOSS5s6+9JEpJXat9UoeYaWIZUn+E6xuJYQ54j0KoG
GmGO06y9JoqUeOoo1m3FqC/V7tyrvwdgJxCNz/ShQT/Oog09FrPI22beDpt/YFHVNziAAziAnwL/
Fg+Ynx6BGPtddgAAAABJRU5ErkJggg==
EOF

## Install menu and desktop shortcuts
cat << EOF > /usr/share/applications/GeoMOOSE.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=GeoMOOSE
Comment=View GeoMOOSE sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=sensible-browser http://localhost/geomoose/geomoose.html
Icon=/usr/share/icons/geomoose.png
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/GeoMOOSE.desktop "$USER_HOME"/Desktop/
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/GeoMOOSE.desktop"

## share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
ln -s /usr/local/geomoose/maps/demo \
      /usr/local/share/data/vector/geomoose


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
