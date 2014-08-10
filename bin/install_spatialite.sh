#!/bin/bash
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
# This script will install spatialite in xubuntu

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

### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

### setup temp ###
mkdir -p "$BUILD_TMP"
cd "$BUILD_TMP"


###########################
### Install from repo ###
## get spatialite cli and libs

echo "Getting and installing spatialite"
apt-get install --assume-yes spatialite-bin 
# Now the GUI and rasterlite libs
apt-get install --assume-yes librasterlite2 rasterlite-bin spatialite-gui



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
  cp "$BUILD_TMP/../app-conf/spatialite/spatialite_${SIZE}px.png" \
    /usr/share/icons/lubuntu/apps/$SIZE/spatialite.png
done
echo "Icon=spatialite" >> /usr/share/applications/spatialite-gui.desktop


#mkdir -p /usr/local/share/applications
#cp "$BUILD_TMP"/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.desktop \
#    /usr/local/share/applications/
#cp $BUILD_TMP/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.desktop \
#    "$USER_HOME"/Desktop/

cp /usr/share/applications/spatialite-gui.desktop "$USER_HOME"/Desktop/
chown "$USER_NAME.$USER_NAME" "$USER_HOME"/Desktop/spatialite-gui.desktop

# tweak to avoid duplication in menus
sed -i -e 's/Database;/Geography;/' /usr/share/applications/spatialite-gui.desktop


#cp "$BUILD_TMP"/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.png \
#    /usr/share/pixmaps/

#cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.desktop \
#    /usr/local/share/applications/
#cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.desktop \
#    "$USER_HOME"/Desktop/
#chown "$USER_NAME.$USER_NAME" "$USER_HOME"/Desktop/spatialite-gis.desktop
#cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.png \
#    /usr/share/pixmaps/



####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
