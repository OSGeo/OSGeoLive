#!/bin/sh
#
# Installation of MapTiler application
#
# Created by Klokan Petr Pridal <petr.pridal@klokantech.com>
#
# Copyright (c) 2010 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.

TMP="/tmp/build_maptiler"
MAPTILERDEB="maptiler_1.0.beta2_all.deb"
DATA_FOLDER="/usr/local/share/maptiler"
TESTDATA_URL="http://download.osgeo.org/gdal/data/gtiff/utm.tif"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


#Can't cd to a directory before you make it, may be uneeded now
mkdir -p "$TMP"
#cd "$TMP"

#Add repositories
echo "FIXME: don't use wget for local files, just copy from local svn checkout."
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
   --output-document=/etc/apt/sources.list.d/ubuntugis.list

#Add signed key for repositorys LTS and non-LTS  (not needed?)
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  
apt-get -q update


# Install dependencies
PACKAGES="python python-wxgtk2.8 python-gdal"

echo "Installing: $PACKAGES"
apt-get --assume-yes install $PACKAGES
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed"
   exit 1
fi


# If MapTiler is not installed then download the .deb package and install it
if [ `dpkg -l maptiler | grep -c '^ii'` -eq 0 ] ; then
  wget -c --progress=dot:mega "http://maptiler.googlecode.com/files/$MAPTILERDEB" \
     --output-document="$TMP/$MAPTILERDEB"
  dpkg -i "$TMP/$MAPTILERDEB"
  #rm "$MAPTILERDEB"
fi

# Test if installation was correct and create the Desktop icon
if [ -e /usr/share/applications/maptiler.desktop ] ; then
  cp /usr/share/applications/maptiler.desktop "$USER_HOME"/Desktop/
  chown "$USER_NAME"."$USER_NAME" "$USER_HOME"/Desktop/maptiler.desktop
else
  echo "ERROR: Installation of the MapTiler failed."
  exit 1
fi

# Create the directory for data
if [ ! -d "$DATA_FOLDER" ] ; then
   mkdir "$DATA_FOLDER"
fi

# Download the data for testing 
cd "$DATA_FOLDER"
wget -N --progress=dot:mega "$TESTDATA_URL"

# Everything is OK
echo "MapTiler is installed"
echo "---------------------"
echo "To try it you should:"
echo ""
echo " 1. Start MapTiler by clicking the icon on the Desktop"
echo " 2. Load in the second step an raster geodata (with georerence/srs), you can try /home/user/data/maptiler/utm.tif"
echo " 3. Go trough all the steps with 'Next' up to the Render"
echo " 4. Once the render is finished you can click in the GUI to open a folder with tiles. When you open googlemaps.html or openlayers.html then you see your geodata warped to the overlay of popular interactive web maps as Google Maps."
echo ""
echo "The map tiles are displayed directly from your disk. To publish the map to Internet just upload the folder with tiles to any webserver or Amazon S3" 

