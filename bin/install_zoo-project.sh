#!/bin/sh
# Copyright (c) 2010-2022 The Open Source Geospatial Foundation and others.
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

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_zoo-project.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_zoo-project.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

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
	zoo-service-status zoo-service-otb zoo-service-openapi zoo-api

## o13 - obsolete, dot-zcfg has been updated
# Patch OTB zcfg files as per ticket #1710
#cd /usr/lib/cgi-bin/OTB
#for i in BandMath Despeckle KMeansClassification; do
#   sed "s:mimeType = image/png:mimeType = image/png\nuseMapserver = true\nmsClassify = true:g" -i $i.zcfg
#done
#sed "s:mimeType = image/png:mimeType = image/png\nuseMapserver = true:g" -i Smoothing.zcfg
##---------------------------------------------

# Download and setup ZOO Project demo files.
cd "$TMP_DIR"
wget -N --progress=dot:mega \
   -O "$TMP_DIR"/examples-livedvd.tar.bz2 \
   "http://download.osgeo.org/livedvd/data/zoo/examples-livedvd.tar.bz2"

tar xf examples-livedvd.tar.bz2
cp -r zoo-demo /var/www/html/zoo-demo
chmod -R 755 /var/www/html/zoo-demo
sed -i -e "s|zoo.dev.publicamundi.eu|zoo-project.org|" /var/www/html/zoo-demo/assets/js/otb-app.js
sed -i '38d' /var/www/html/zoo-demo/otb-example.html
# cp zoo-demo/main.cfg /etc/zoo-project/
cp -f "$BUILD_DIR/../app-conf/zoo-project/main.cfg" \
    /etc/zoo-project/

# FIXME: Use another folder than /var/data See #1850
mkdir -p /var/data
cp zoo-demo/symbols.sym /var/data/
cp /var/lib/zoo-project/updateStatus.xsl /var/data/
ln -s /tmp /var/www/html/mpPathRelativeToServerAdress
chown -R www-data:www-data /var/data
rm -rf zoo-demo

cat << EOF > /etc/ld.so.conf.d/zoo-project.conf
/usr/lib/jvm/default-java/jre/lib/${ARCH}/server
EOF

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
