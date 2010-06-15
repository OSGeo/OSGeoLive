#!/bin/sh
#################################################
# 
# Purpose: Install a sample of the Natural Earth Datasets
# Source:  http://www.naturalearthdata.com/
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2009 LISAsoft
#
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
##################################################


# Running:
# =======
# sudo ./install_gisdata.sh

TMP="/tmp/build_gisdata"
#INSTALL_FOLDER="/usr/lib"
DATA_FOLDER="/usr/local/share/data/gisdata"
#BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
 
## Setup things... ##
if [ ! -d "$DATA_FOLDER" ] ; then
   mkdir "$DATA_FOLDER"
fi
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
mkdir "$TMP"
cd "$TMP"

# Download natural earth datasets:

# Simple Populated Places 1:110m
# http://www.naturalearthdata.com/downloads/110m-cultural-vectors/
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/110m-populated-places-simple.zip"

# Admin 0 - Countries 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/110m-admin-0-countries.zip"

# Populated Places (simple, less columns) 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/110m-populated-places-simple.zip"

# Land 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/110m-land.zip"

# Ocean 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/110m-ocean.zip"

# Lakes + Reservoirs 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/110m-lakes.zip"

# Rivers, Lake Ceterlines 1:110m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/physical/110m-rivers-lake-centerlines.zip"

# Raster basemap
# Cross Blended Hypso with Shaded Relief and Water 1:50m
wget -c --progress=dot:mega "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/raster/HYP_50M_SR_W.zip"

# Unzip files into the gisdata directory
for file in *.zip ; do
  unzip ${file} -d "$DATA_FOLDER"
done

# Install Open Street Map data for one city (usually the FOSS4G host city)
# Barcelona data:
#  Having a sample .osm file around will benefit many applications. In addition
#  to JOSM and Gosmore, QGIS and Mapnik can also render .osm directly.
#  grab Barcelona, which can be as easy as:
#
# $ wget -O barcelona.osm http://osmxapi.hypercube.telascience.org/api/0.6/map?bbox=1.998653,41.307213,2.343693,41.495207
#
# We should also push the .osm file into postgis/postgres with osm2pgsql.
#
# $ createdb -T template_postgis osm_barcelona
# $ osm2pgsql -d osm_barcelona barcelona.osm
# 

### Please update to latest data at the last minute! See data dir on server for details.
#wget --progress=dot:mega "http://download.osgeo.org/livedvd/data/osm/Barcelona.osm.bz2"

#download as part of disc build process
# Downloading from the osmxapi takes me about 6 minutes and is around 20MB.
# hypercube is near the OSGeo servers at SDSC so should be much faster.

if [ ! -e 'highlightedcity.osm.bz2' ] ; then
  XAPI_URL="http://osmxapi.hypercube.telascience.org/api/0.6"
  BBOX="1.998653,41.307213,2.343693,41.495207"

  wget --progress=dot:mega -O highlightedcity.osm  "$XAPI_URL/map?bbox=$BBOX"
  if [ $? -ne 0 ] ; then
     echo "ERROR getting osm data"
     exit 1
  fi
  bzip2 highlightedcity.osm
fi
cp -f highlightedcity.osm.bz2 ${DATA_FOLDER}
