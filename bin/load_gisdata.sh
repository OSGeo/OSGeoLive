#!/bin/sh
#################################################
#
# Purpose: Install common geodata, including:
#    - A sample of the Natural Earth Datasets
#    - The OSGeo North Carolina common dataset
#    [OpenStreetMap data is installed by the install_osm script]
# Source:  http://www.naturalearthdata.com
#
#################################################
# Copyright (c) 2010-2024 Open Source Geospatial Foundation (OSGeo) and others.
# Copyright (c) 2009 LISAsoft
#
# Licensed under the GNU LGPL version >= 2.1.
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


TMP="/tmp/build_gisdata"
DATA_FOLDER="/usr/local/share/data"
NE2_DATA_FOLDER="$DATA_FOLDER/natural_earth2"
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

##------------------------
# create tmp folders
mkdir "$TMP"
cd "$TMP"


##################################
# Download netCDF datasets:
#

# mkdir -p  /usr/local/share/data/netcdf
# mkdir netcdf; cd netcdf

# t_netcdf_files="
# README_netCDF_samples.txt
# rx5dayETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc
# rx5dayETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc.txt
# rx5dayETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc
# rx5dayETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc.txt
# txxETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc
# txxETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc.txt
# txxETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc
# txxETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc.txt
# "
# for n in $t_netcdf_files; do
# 	wget -c -N --progress=dot:mega http://download.osgeo.org/livedvd/data/netcdf/$n
# done

# mv * /usr/local/share/data/netcdf/
# cd ..
# rm -rf netcdf


##################################
# Download natural earth datasets:

mkdir -p "$NE2_DATA_FOLDER"

BASE_URL="https://naciscdn.org"
USE_NE_UNMODIFIED=false

if $USE_NE_UNMODIFIED; then

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
cultural/ne_${SCALE}_populated_places_simple
cultural/ne_${SCALE}_admin_0_countries
cultural/ne_${SCALE}_admin_1_states_provinces_shp
cultural/ne_${SCALE}_urban_area
physical/ne_${SCALE}_geography_regions_polys
physical/ne_${SCALE}_geography_regions_points
physical/ne_${SCALE}_geography_regions_elevation_points
physical/ne_${SCALE}_geography_marine_polys
physical/ne_${SCALE}_land
physical/ne_${SCALE}_ocean
physical/ne_${SCALE}_lakes
physical/ne_${SCALE}_rivers_lake_centerlines
"

    if [ ! -e $TMP/"ne_$SCALE_populated_places_simple.zip" ]; then
      for LAYER in $LAYERS ; do
             wget --progress=dot:mega -O "`basename $LAYER`.zip" \
               "$BASE_URL/naturalearth/$SCALE/$LAYER.zip"
      done
    fi

    # Unzip files into the gisdata directory
    for file in *.zip ; do
      unzip -q "$file" -d "$DATA_FOLDER/natural_earth"
    done

else
    ## use a pre-built vectors set rather than naturalearthdata URLs
    wget -c --progress=dot:mega http://download.osgeo.org/livedvd/data/natural_earth2/all_10m_20.tgz
    tar xzf all_10m_20.tgz
    for tDir in ne_10m_*; do
       mv "$tDir"/* "$NE2_DATA_FOLDER"
    done
fi

## Get Raster basemap -- Cross Blended Hypso with Shaded Relief and Water
#    1:50 million (97mb, reduce to 7.2mbmb)
#RFILE="HYP_50M_SR_W.zip"
RFILE=HYP_50M_SR_W_reduced.zip
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/natural_earth2/$RFILE"

#	"$BASE_URL/http//www.naturalearthdata.com/download/50m/raster/$RFILE"

unzip "$RFILE"

#mv HYP_50M_SR_W.tif HYP_50M_SR_W_orig.tif
#
#gdal_translate HYP_50M_SR_W_orig.tif HYP_50M_SR_W.tif \
#  -co compress=jpeg -co photometric=ycbcr -co tiled=yes \
#  -co JPEG_QUALITY=90
#
#rm HYP_50M_SR_W_orig.tif "$RFILE"
rm "$RFILE"

mv HYP_* "$NE2_DATA_FOLDER"


##--------------------------------
# use ogrinfo to create spatial index
cd "$NE2_DATA_FOLDER"
for SHP in *.shp; do \
      S=`basename $SHP .shp`
      ogrinfo -sql "CREATE SPATIAL INDEX ON $S" $SHP;
done
cd "$TMP"

##--------------------------------
chmod a+r "$NE2_DATA_FOLDER"     ## read the data dir
chmod 444 "$NE2_DATA_FOLDER"/*   ##  and all files in it
chmod -R +X "$NE2_DATA_FOLDER"   ## but keep x on directories
chown -R root.users "$NE2_DATA_FOLDER"

##--------------------------------------
## load natural earth 2 data into postgis 2
##  TODO dec12 check locale results and update this
SRC_DIR="$NE2_DATA_FOLDER"
sudo -u $POSTGRES_USER createdb natural_earth2
sudo -u $POSTGRES_USER psql natural_earth2 -c 'create extension postgis;'

for n in "$SRC_DIR"/*.shp;
do
  shp2pgsql -W LATIN1 -s 4326 -I -g geom "$n" | \
     sudo -u $POSTGRES_USER psql --quiet natural_earth2
done

sudo -u $POSTGRES_USER psql natural_earth2 --quiet -c "vacuum analyze"


#################################################
# Install metadata sample (some other stuff comes along for the ride)
# FIXME: please rename the package to something less generic.
# FIXME: replace with North Carolina &/or Natural Earth metadata

#apt-get install python-gisdata

# Link to shared data folder
#ln -s /usr/lib/python2.7/dist-packages/gisdata/metadata/good \
#   /usr/local/share/data/metadata


#################################################
# Download the North Carolina sample dataset
#  contact: geodata at lists dot osgeo.org
# about: http://www.grassbook.org/data_menu3rd.php
# license: Creative Commons
# metadata index: http://www.grassbook.org/ncexternal/nc_datalist.html

# grab shapefiles, geotiffs, and KMLs (~100mb total)
FILES="shape rast_geotiff kml"
# FILES="shape kml"
BASE_URL="http://grass.osgeo.org/sampledata/north_carolina"

cd "$TMP"
mkdir -p nc_data
cd nc_data

mkdir -p "$DATA_FOLDER/north_carolina"

##-- useful metadata  31jan15
##-- TODO: wget -N http://www.grassbook.org/presentations/MitOSGeoDataFOSS4G9.pdf
wget -N http://www.grassbook.org/grasslocations/nc_epsg_codes.html
wget -N http://grass.osgeo.org/sampledata/north_carolina/README.html

mv nc_epsg_codes.html README.html "$DATA_FOLDER/north_carolina/"

#--
for FILE in $FILES ; do
   wget -N --progress=dot:mega "$BASE_URL/nc_$FILE.tar.gz"
done

#and install them ...
cd "$DATA_FOLDER/north_carolina"
for FILE in $FILES ; do
   mkdir -p "$FILE"
   cd "$FILE"
   tar xzf "$TMP/nc_data/nc_$FILE.tar.gz"
   mv nc*/* .
   rmdir nc*/
   cd ..
   chgrp users "$FILE"
   chmod g+w "$FILE"
done

touch "$DATA_FOLDER"/north_carolina/shape/epsg-3358.txt
cd "$TMP"

# # add landsat and srtm dataset
# cd $DATA_FOLDER
# wget -N --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/landsat.tar.gz"
# tar xzf landsat.tar.gz
# chgrp users landsat
# chmod g+w landsat
# rm -rf landsat.tar.gz

# # make srtm elevation
# /usr/bin/ossim-orthoigen --writer general_raster_bip \
#    "$DATA_FOLDER/landsat/srtm.tif" \
#    /usr/share/ossim/elevation/srtm/srtm.ras

# unset OSSIM_PREFS_FILE


chown -R root.root "$DATA_FOLDER"/north_carolina


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
