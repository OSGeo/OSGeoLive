#!/bin/sh
# Copyright (c) 2010-2016 The Open Source Geospatial Foundation.
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
# This script will install ZOO Project
#
# Requires: Apache2, GeoServer (for the demo only)


./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


TMP_DIR=/tmp/build_zoo
if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

apt-get --assume-yes install zoo-kernel zoo-service-ogr zoo-api

# Download ZOO Project deb file.
wget -N --progress=dot:mega \
   -O "$TMP_DIR"/examples.7z \
   "http://download.osgeo.org/livedvd/data/zoo/examples.7z"

7zr x examples.7z 
cp -r examples /var/www/html/zoo-demo
chmod -R 755 /var/www/html/zoo-demo

wget --progress=dot:mega \
  -O /usr/share/icons/zoo-icon.png \
  "http://download.osgeo.org/livedvd/data/zoo/zoo-icon.png"

# Add desktop file
cat << EOF > /usr/share/applications/zoo-project.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=ZOO Project
Comment=ZOO Project Demo
Categories=Application;Education;Geography;
Exec=firefox http://localhost/zoo-demo
Icon=/usr/share/icons/zoo-icon.png
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/zoo-project.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/zoo-project.desktop"

# Reload Apache
/etc/init.d/apache2 force-reload

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
