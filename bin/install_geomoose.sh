#!/bin/sh
#############################################################################
#
# Purpose: This script will install geomoose
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

# Requires: Apache2, MapServer

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p /tmp/build-geomoose

cd /tmp/build-geomoose

## Download and extract GeoMOOSE 3.10.1
wget -c --tries=3 --progress=dot:mega --no-check-certificate \
   "https://www.geomoose.org/downloads/gm3-examples-3.10.1.zip"
wget -c --tries=3 --progress=dot:mega --no-check-certificate \
   "https://www.geomoose.org/downloads/gm3-demo-data-3.10.1.zip"

unzip -qo gm3-examples-3.10.1.zip
unzip -qo gm3-demo-data-3.10.1.zip

rm -rf /usr/local/geomoose

mkdir -p /usr/local/geomoose

cd /usr/local/geomoose

mv /tmp/build-geomoose/gm3-examples .
mv /tmp/build-geomoose/gm3-demo-data .

## Setup htdocs directory to be available to apache
rm -f /var/www/html/geomoose
ln -s /usr/local/geomoose/gm3-examples/htdocs /var/www/html/geomoose

## Configure GeoMOOSE 3.10.1
cat > /usr/local/geomoose/gm3-examples/htdocs/desktop/config.js <<'EOF'
CONFIG = {
    mapserver_url: "/cgi-bin/mapserv",
    mapfile_root: "/usr/local/geomoose/gm3-demo-data/"
};
EOF

cat > /usr/local/geomoose/gm3-examples/htdocs/mobile/config.js <<'EOF'
CONFIG = {
    mapserver_url: "/cgi-bin/mapserv",
    mapfile_root: "/usr/local/geomoose/gm3-demo-data/"
};
EOF

cat > /usr/local/geomoose/gm3-demo-data/temp_directory.map <<'EOF'
# This file is used to configure temporary directories for Mapserver Mapfile

IMAGEPATH "/tmp/"

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
cat << EOF > /usr/share/applications/GeoMoose3.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=GeoMoose 3
Comment=View GeoMoose sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=sensible-browser http://localhost/geomoose/desktop/index.html
Icon=/usr/share/icons/geomoose.png
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/GeoMoose3.desktop "$USER_HOME"/Desktop/
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/GeoMoose3.desktop"

## share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
rm -f /usr/local/share/data/vector/geomoose
ln -s /usr/local/geomoose/gm3-demo-data \
      /usr/local/share/data/vector/geomoose


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
