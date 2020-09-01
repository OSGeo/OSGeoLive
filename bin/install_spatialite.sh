#!/bin/bash
#############################################################################
#
# Purpose: This script will install spatialite
#
#############################################################################
# Copyright (c) 2009-2020 The Open Source Geospatial Foundation and others.
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

BUILD_TMP="/tmp/build_spatialite"
DATA_FOLDER="/usr/local/share/data"
PKG_DATA=$DATA_FOLDER/spatialite

## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

### setup temp ###
mkdir -p "$BUILD_TMP"
cd "$BUILD_TMP"

echo "Getting and installing spatialite"
apt-get install --assume-yes spatialite-bin spatialite-gui sqlite3
# Saves ~40MB of disk space. To enable back if absolutely needed.
# apt-get install --assume-yes sqlitebrowser

##########################
### Sample data ###
# New trento.sqlite downloaded from download.osgeo.org 
OSGEO_URL=http://download.osgeo.org/livedvd/data/spatialite
SQLITE_DB=trento.sqlite.tar.gz
if [ ! -d "$PKG_DATA" ]
then
    echo "Creating $PKG_DATA directory"
    mkdir -p "$PKG_DATA"
fi

wget -N --progress=dot:mega "$OSGEO_URL/$SQLITE_DB"
(cd "$PKG_DATA" && tar xzf "$BUILD_TMP/$SQLITE_DB")

chgrp -R users "$PKG_DATA"
chmod -R g+w "$PKG_DATA"
chmod -R a-x "$PKG_DATA"/*


#############################
### GUI start icons ###
# copy icons into somewhere where they might get picked up (how do do this into /usr/local?)
for SIZE in 16 32 48 64 ; do
  cp "$BUILD_DIR/../app-conf/spatialite/spatialite_${SIZE}px.png" \
    /usr/share/icons/hicolor/${SIZE}x${SIZE}/apps/spatialite.png
done
# bah, 'Icon=spatialite' isn't working for some reason
echo "Icon=/usr/share/icons/hicolor/32x32/apps/spatialite.png" \
  >> /usr/share/applications/spatialite-gui.desktop


cp /usr/share/applications/spatialite-gui.desktop "$USER_HOME"/Desktop/
chown "$USER_NAME.$USER_NAME" "$USER_HOME"/Desktop/spatialite-gui.desktop

# tweak to avoid duplication in menus
sed -i -e 's/Database;/Geography;/' /usr/share/applications/spatialite-gui.desktop

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
