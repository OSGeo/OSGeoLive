#!/bin/sh
#############################################################################
#
# Purpose: This script will install GeoExt 3.1, OpenLayers 4.6.5, and ExtJS 6.2
#
#############################################################################
# Copyright (c) 2019-2020 The Open Source Geospatial Foundation and others.
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

# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/geoext/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_geoext"

GEOEXT_VERSION="3.1.0"
OPENLAYERS_VERSION="4.6.5"
GEOEXT_DIR=/var/www/html/geoext
EXTJS_VERSION="6.2.0"

#
# Install ExtJS
#
echo "\nCreating temporary directory $TMP_DIR..."
mkdir -p "$TMP_DIR"
echo "\nCreating GeoExt directory GEOEXT_DIR..."
mkdir -p "$GEOEXT_DIR"

echo "\nDownloading ExtJS..."
cd "$TMP_DIR"
if [ -f "ext-$EXTJS_VERSION-gpl.zip" ]
then
   echo "ext-$EXTJS_VERSION-gpl.zip has already been downloaded."
else
   wget -c --progress=dot:mega \
      "http://cdn.sencha.com/ext/gpl/ext-$EXTJS_VERSION-gpl.zip"
fi

echo "\nInstalling ExtJS..."
unzip -qo "ext-$EXTJS_VERSION-gpl.zip"
cd "ext-$EXTJS_VERSION"

mv build/ext-all.js "$GEOEXT_DIR"/
mv LICENSE "$GEOEXT_DIR/LICENSE-EXTJS"
mv build/classic/theme-triton/resources "$GEOEXT_DIR"/
chmod -R uga+r "$GEOEXT_DIR"

echo "\nCleaning up..."
cd "$TMP_DIR"
rm -rf "ext-$EXTJS_VERSION"
rm -f "ext-$EXTJS_VERSION-gpl.zip"

#
# Install OpenLayers
#
echo "\nInstalling OpenLayers..."

cd "$TMP_DIR"

OPENLAYERS_ARCHIVE_DIST="v$OPENLAYERS_VERSION-dist.zip"
if [ -f "$OPENLAYERS_ARCHIVE_DIST" ]
then
   echo "OpenLayers $OPENLAYERS_VERSION distribution version has already been downloaded. Skipping download."
else
   wget -c --progress=dot:mega \
      "https://github.com/openlayers/openlayers/releases/download/v$OPENLAYERS_VERSION/v$OPENLAYERS_VERSION-dist.zip"
   echo "OpenLayers $OPENLAYERS_VERSION distribution version download complete."
fi

#
# Unzip 
#
echo "\nUnzipping archive..."
unzip -qo $OPENLAYERS_ARCHIVE_DIST
echo "Unzipping done"

#
# Copy to www
#
echo "\nCopying files to $GEOEXT_DIR"
cd v$OPENLAYERS_VERSION-dist
mv ol.css "$GEOEXT_DIR"/
mv ol.js "$GEOEXT_DIR"/
echo "Copying done"

echo "\nCleaning up..."
cd "$TMP_DIR"
rm -rf v$OPENLAYERS_VERSION-dist
rm -f $OPENLAYERS_ARCHIVE_DIST

#
# Install GeoExt
#

echo "\nInstalling GeoExt..."

cd "$TMP_DIR"

GEOEXT_ARCHIVE_DIST="v$GEOEXT_VERSION.zip"
if [ -f "$GEOEXT_ARCHIVE_DIST" ]
then
   echo "GeoExt $GEOEXT_ARCHIVE_DIST distribution version has already been downloaded. Skipping download."
else
   wget -c --progress=dot:mega \
      "https://github.com/geoext/geoext3/archive/$GEOEXT_ARCHIVE_DIST"
   echo "OpenLayers $GEOEXT_VERSION distribution version download complete."
fi

#
# Unzip 
#
echo "\nUnzipping archive..."
unzip -qo $GEOEXT_ARCHIVE_DIST
echo "Unzipping done"

#
# Copy to www
#
echo "\nCopying files to $GEOEXT_DIR"
cd geoext3-$GEOEXT_VERSION
mv src "$GEOEXT_DIR"/
mv LICENSE "$GEOEXT_DIR/LICENSE-GEOEXT"
echo "Copying done"

echo "\nCleaning up..."
cd "$TMP_DIR"
rm -rf geoext3-$GEOEXT_VERSION
rm -f $GEOEXT_ARCHIVE_DIST

#
# Install desktop icon and demo
#

cp -f "$BUILD_DIR/../app-conf/geoext/GeoExt-logo.png" \
       /usr/local/share/icons/geoext.png

cp -f "$BUILD_DIR/../app-conf/geoext/geoext-demo.html" "$GEOEXT_DIR/index.html"

#
# Launch script and icon for GeoExt
#
echo "\nGenerating launcher..."

if [ ! -e /usr/share/applications/geoext.desktop ] ; then
   cat << EOF > /usr/share/applications/geoext.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=GeoExt
Comment=GeoExt Demo
Categories=Application;Internet;
Exec=firefox http://localhost/geoext/ http://localhost/osgeolive/en/quickstart/geoext_quickstart.html
Icon=geoext
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/share/applications/geoext.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/geoext.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
