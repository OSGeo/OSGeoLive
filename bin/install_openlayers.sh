#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install OpenLayers 3.0.0 (and OpenLayers 2.13.1 for legacy demos in OSGeoLive)
#
# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/ol3/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_openlayers"
OL3_VERSION="3.1.1"
OL2_VERSION="2.13.1" 
OL3_DIR=/var/www/html/ol3
OL3_SRC_DIR=/usr/share/openlayers3
OL2_DIR=/var/www/html/openlayers

#
# Install OpenLayers 2
#
echo "\nCreating temporary directory $TMP_DIR..."
mkdir -p "$TMP_DIR"
echo "\nCreating OpenLayers2 directory $OL2_DIR..."
mkdir -p "$OL2_DIR"
echo "\nCreating OpenLayers3 directory $OL3_DIR..."
mkdir -p "$OL3_DIR"

echo "\nDownloading OpenLayers2..."
cd "$TMP_DIR"
if [ -f "OpenLayers-$OL2_VERSION.tar.gz" ]
then
   echo "OpenLayers-$OL2_VERSION.tar.gz has already been downloaded."
else
   wget -c --progress=dot:mega \
      "http://github.com/openlayers/openlayers/releases/download/release-$OL2_VERSION/OpenLayers-$OL2_VERSION.tar.gz"
fi

echo "\nInstalling OpenLayers2..."
tar zxf "OpenLayers-$OL2_VERSION.tar.gz"
cd "OpenLayers-$OL2_VERSION"
mv OpenLayers.js "$OL2_DIR"/
mv img "$OL2_DIR"/
mv theme "$OL2_DIR"/
chmod -R uga+r "$OL2_DIR"

echo "\nCleaning up..."
cd "$TMP_DIR"
rm -rf "OpenLayers-$OL2_VERSION"
rm "OpenLayers-$OL2_VERSION.tar.gz"

#
# Install OpenLayers 3
#
echo "\nInstalling OpenLayers3..."
wget -c --progress=dot:mega \
   "http://aiolos.survey.ntua.gr/gisvm/dev/libjs-openlayers3_3.1.1-1_all.deb"
dpkg -i libjs-openlayers3_3.1.1-1_all.deb
rm -rf libjs-openlayers3_3.1.1-1_all.deb

#
# Generate index page
#
cd "$OL3_DIR"

echo "\nGenerating index file..."
cat << EOF > "index.html"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
<body>
<h1>OpenLayers $OL3_VERSION</h1>
<p>Welcome to OpenLayers index page:</p>
<ul>
<li><a href="apidoc/">API Docs</a>: explore the project documentation</li>
<li><a href="examples/">Examples</a>: see the project in action</li>
<li><a href="http://openlayers.org/">OpenLayers.org website</a></li>
</ul>
</body>
</html>
EOF

#
# Link files to apache dir
#
echo "\nConfiguring web directory..."

ln -s "$OL3_SRC_DIR"/hosted/master/apidoc "$OL3_DIR"/apidoc
ln -s "$OL3_SRC_DIR"/hosted/master/build "$OL3_DIR"/build
ln -s "$OL3_SRC_DIR"/hosted/master/css "$OL3_DIR"/css
ln -s "$OL3_SRC_DIR"/hosted/master/examples "$OL3_DIR"/examples
ln -s "$OL3_SRC_DIR"/hosted/master/ol "$OL3_DIR"/ol
ln -s "$OL3_SRC_DIR"/hosted/master/resources "$OL3_DIR"/resources
chmod -R uga+r "$OL3_DIR"

#
# Launch script and icon for OpenLayers to take you to a documentation 
# page and examples listing
#
echo "\nGenerating launcher..."
cp "$OL3_SRC_DIR/hosted/master/resources/logo.png" /usr/share/pixmaps/openlayers.png

if [ ! -e /usr/share/applications/openlayers.desktop ] ; then
   cat << EOF > /usr/share/applications/openlayers.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenLayers
Comment=Sample constructions
Categories=Application;Internet;
Exec=firefox http://localhost/ol3/ http://localhost/en/quickstart/openlayers_quickstart.html
Icon=openlayers
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/openlayers.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/openlayers.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
