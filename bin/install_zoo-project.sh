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

apt-get --assume-yes install zoo-kernel zoo-service-ogr \
	zoo-service-status zoo-service-cgal zoo-service-otb zoo-api

# Patch OTB zcfg files as per ticket #1710
cd /usr/lib/cgi-bin/OTB
for i in BandMath Despeckle KMeansClassification; do
   sed "s:mimeType = image/png:mimeType = image/png\nuseMapserver = true\nmsClassify = true:g" -i $i.zcfg
done
sed "s:mimeType = image/png:mimeType = image/png\nuseMapserver = true:g" -i Smoothing.zcfg

# Download and setup ZOO Project demo files.
cd "$TMP_DIR"
wget -N --progress=dot:mega \
   -O "$TMP_DIR"/examples-livedvd.tar.bz2 \
   "http://download.osgeo.org/livedvd/data/zoo/examples-livedvd.tar.bz2"

tar xf examples-livedvd.tar.bz2
cp -r zoo-demo /var/www/html/zoo-demo
chmod -R 755 /var/www/html/zoo-demo
cp zoo-demo/main.cfg /usr/lib/cgi-bin/
# FIXME: Use another folder than /var/data See #1850
mkdir -p /var/data
cp zoo-demo/symbols.sym /var/data/
cp /usr/share/zoo-service-status/updateStatus.xsl /var/data/
ln -s /tmp /var/www/html/mpPathRelativeToServerAdress
chown -R www-data:www-data /var/data
rm -rf zoo-demo

# Get ZOO-Project icon
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
