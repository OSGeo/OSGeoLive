#!/bin/sh
#################################################
# 
# Purpose: Install a sample of the Natural Earth Datasets
# Source:  http://www.naturalearthdata.com
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
#
# Licensed under the GNU LGPL.
# 
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This program is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# the web page "http://www.fsf.org/licenses/lgpl.html".
##################################################

TMP="/tmp/build_gisdata"
DATA_FOLDER="/usr/local/share/data"
POSTGRES_USER="user"
 
## Setup things... ##
if [ ! -d "$DATA_FOLDER" ] ; then
   mkdir -p "$DATA_FOLDER"
fi
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
mkdir "$TMP"
cd "$TMP"



###############################
# Download natural earth datasets:

BASE_URL="http://www.naturalearthdata.com"
SCALE="10m"  # 1:10 million

# Simple Populated Places 1:10m
#    http://www.naturalearthdata.com/downloads/10m-cultural-vectors/
# Admin 0 - Countries 1:10m
# Populated Places (simple, less columns) 1:10m
# Land 1:10m
# Ocean 1:10m
# Lakes + Reservoirs 1:10m
# Rivers, Lake Ceterlines 1:10m
LAYERS="
cultural/$SCALE-populated-places-simple
cultural/$SCALE-admin-0-countries
cultural/$SCALE-populated-places-simple
cultural/$SCALE-urban-area
physical/$SCALE-land
physical/$SCALE-ocean
physical/$SCALE-lakes
physical/$SCALE-rivers-lake-centerlines
"

for LAYER in $LAYERS ; do
   wget --progress=dot:mega -O "`basename $LAYER`.zip" \
     "$BASE_URL/http//www.naturalearthdata.com/download/$SCALE/$LAYER.zip"
done

# Raster basemap -- Cross Blended Hypso with Shaded Relief and Water 1:50 million (40mb)
wget -c --progress=dot:mega \
   "$BASE_URL/http//www.naturalearthdata.com/download/50m/raster/HYP_50M_SR_W.zip"


# Unzip files into the gisdata directory
mkdir -p "$DATA_FOLDER/natural_earth"

for file in *.zip ; do
  unzip "$file" -d "$DATA_FOLDER/natural_earth"
done

chmod a+r "$DATA_FOLDER/natural_earth"     ## read the data dir
chmod a+r "$DATA_FOLDER/natural_earth/*"   ##  and all files in it
chmod u-wx "$DATA_FOLDER/natural_earth/*"  ## no, don't exec a data file
chmod -R +X "$DATA_FOLDER/natural_earth"   ## but keep x on directories

##--------------------------------------
## load natural earth data into postgis

SRC_DIR="$DATA_FOLDER/natural_earth"
sudo -u $POSTGRES_USER createdb natural_earth -T template_postgis

for n in $SRC_DIR/*shp;
do
  shp2pgsql -W LATIN1 -s 4326 -I -g the_geom $n | sudo -u $POSTGRES_USER psql --quiet natural_earth
done

sudo -u $POSTGRES_USER psql natural_earth --quiet -c "vacuum analyze"

###############################
# Link to Open Street Map data  (e.g. FOSS4G host city)
CITY="Barcelona"
if [ -e "/usr/local/share/osm/$CITY.osm.bz2" ] ; then
   mkdir -p "$DATA_FOLDER/osm" --verbose
   ln -s "/usr/local/share/osm/$CITY.osm.bz2" "$DATA_FOLDER/osm/feature_city.osm.bz2"
else
   echo "ERROR: $CITY.osm.bz2 not found. Run install_osm.sh first."
fi


