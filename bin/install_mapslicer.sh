#!/bin/sh
#
# Install the MapSlicer application
#
# Created by Klokan Petr Pridal <petr.pridal@klokantech.com>
#
# Copyright (c) 2010-15 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_mapslicer"
MAPSLICERDEB="mapslicer_1.0.rc1_all.deb"
DATA_FOLDER="/usr/local/share/mapslicer"
TESTDATA_URL="http://download.osgeo.org/gdal/data/gtiff/utm.tif"


#Can't cd to a directory before you make it, may be uneeded now
mkdir -p "$TMP"

# Install dependencies
PACKAGES="python python-wxgtk2.8 python-gdal"

echo "Installing: $PACKAGES"
apt-get --assume-yes install $PACKAGES
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed"
   exit 1
fi


# If MapSlicer is not installed then download the .deb package and install it
if [ `dpkg -l mapslicer | grep -c '^ii'` -eq 0 ] ; then
  wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/mapslicer/$MAPSLICERDEB" \
     --output-document="$TMP/$MAPSLICERDEB"
  dpkg -i "$TMP/$MAPSLICERDEB"
  #rm "$MAPSLICERDEB"
fi

ln -s /usr/lib/mapslicer/mapslicer.py /usr/bin/mapslicer

# for file picker, recently-used.xbel
mkdir -p /etc/skel/.local/share

# gdal 1.10 does not like epsg code 900913, replace with (trac #1391)
sed -i -e 's/EPSG(900913)/EPSG(3857)/' \
       -e 's/"EPSG:900913"/"EPSG:3857"/' \
   /usr/lib/mapslicer/mapslicer/gdal2tiles.py \
   /usr/bin/gdal2tiles.py


# Test if installation was correct and create the Desktop icon
if [ -e /usr/share/applications/mapslicer.desktop ] ; then
  cp /usr/share/applications/mapslicer.desktop "$USER_HOME"/Desktop/
  chown "$USER_NAME"."$USER_NAME" "$USER_HOME"/Desktop/mapslicer.desktop
  sed -i -e 's/Graphics;/Geography;/' /usr/share/applications/mapslicer.desktop
else
  echo "ERROR: Installation of the MapSlicer failed."
  exit 1
fi

# Create the directory for data
if [ ! -d "$DATA_FOLDER" ] ; then
   mkdir "$DATA_FOLDER"
fi

# Download the data for testing 
cd "$DATA_FOLDER"
wget -N --progress=dot:mega "$TESTDATA_URL"

# make it available to all projects:
mkdir -p /usr/local/share/data/raster
ln -s "$DATA_FOLDER/utm.tif" /usr/local/share/data/raster/utm11N.tif

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
