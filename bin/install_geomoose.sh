#!/bin/bash
#
# Copyright (c) 2009-2010 The Open Source Geospatial Foundation.
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
# This script will install geomoose

# Running:
# =======
# sudo ./install_geomoose.sh

apt-get install php5-sqlite

USER_NAME="user"
USER_DIR="/home/user"

mkdir -p /tmp/build-geomoose

cd /tmp/build-geomoose

# Download and extract GeoMOOSE 2.4
wget -c "http://www.geomoose.org/downloads/geomoose-2.4.tar.gz"
wget -c "http://www.geomoose.org/downloads/geomoose-2.4-mapserver-6.patch"

tar -xzf geomoose-2.4.tar.gz

rm -rf /usr/local/geomoose

mkdir -p /usr/local/geomoose

cd /usr/local/geomoose

mv /tmp/build-geomoose/geomoose*/* .

# Configure GeoMOOSE 2.4 (Builds configuration files from templates)
./configure --with-url-path=/geomoose --with-temp-directory=/tmp/ --with-mapfile-root=/usr/local/geomoose/maps/

# Setup htdocs directory to be available to apache
ln -s /usr/local/geomoose/htdocs /var/www/geomoose

# Patch GeoMOOSE State Demo layer to work with MapServer 6.x
# Patches are submitted upstream and will likely be included
# (or their equivlent) in GeoMOOSE 2.6.
patch -p1 < /tmp/build-geomoose/geomoose-2.4-mapserver-6.patch

## Install menu and desktop shortcuts
## Skip right now for lack of sutiable icon
#cat << EOF > /usr/share/applications/GeoMOOSE.desktop
#[Desktop Entry]
#Version=1.0
#Encoding=UTF-8
#Type=Application
#Name=GeoMOOSE
#Comment=View GeoMOOSE sample application in browser
#Categories=Application;Geography;Geoscience;Education;
#Exec=sensible-browser http://localhost/geomoose/geomoose.html
#Icon=/usr/share/icons/geomoose.png
#Terminal=false
#StartupNotify=false
#EOF
#cp /usr/share/applications/GeoMOOSE.desktop $USER_DIR/Desktop/
#chown $USER_NAME:$USER_NAME $USER_DIR/Desktop/GeoMOOSE.desktop

