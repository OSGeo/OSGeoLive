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
# Copyright (c) 2010-2022 Open Source Geospatial Foundation (OSGeo) and others.
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

##-- patch feb15 -- pdf from where ?
#rm /usr/local/share/doc/Getting_Started_with_Ubuntu_13.10.pdf

##------------------------
# create tmp folders
mkdir "$TMP"
cd "$TMP"


##################################
# Download netCDF datasets:
#

mkdir -p  /usr/local/share/data/netcdf
mkdir netcdf; cd netcdf

t_netcdf_files="
README_netCDF_samples.txt
rx5dayETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc
rx5dayETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc.txt
rx5dayETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc
rx5dayETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc.txt
txxETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc
txxETCCDI_yr_MIROC5_historical_r2i1p1_1850-2012.nc.txt
txxETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc
txxETCCDI_yr_MIROC5_rcp45_r2i1p1_2006-2100.nc.txt
"
for n in $t_netcdf_files; do
	wget -c -N --progress=dot:mega http://download.osgeo.org/livedvd/data/netcdf/$n
done

mv * /usr/local/share/data/netcdf/
cd ..
rm -rf netcdf


##################################
# Download natural earth datasets:
#  nov12: data 2.0 to postgis 2.0

mkdir -p "$NE2_DATA_FOLDER"

BASE_URL="http://www.naturalearthdata.com"

USE_NE_UNMODIFIED=false		# live 4.5b1 process hack

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
cultural/$SCALE-populated-places-simple
cultural/$SCALE-admin-0-countries
cultural/$SCALE-admin-1-states-provinces-shp
cultural/$SCALE-urban-area
physical/$SCALE-geography-regions-polys
physical/$SCALE-geography-regions-points
physical/$SCALE-geography-regions-elevation-points
physical/$SCALE-geography-marine-polys
physical/$SCALE-land
physical/$SCALE-ocean
physical/$SCALE-lakes
physical/$SCALE-rivers-lake-centerlines
"

    if [ ! -e $TMP/"$SCALE_populated_places_simple.zip" ]; then
      for LAYER in $LAYERS ; do
    	     wget --progress=dot:mega -O "`basename $LAYER`.zip" \
    	       "$BASE_URL/http//www.naturalearthdata.com/download/$SCALE/$LAYER.zip"
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
if [ "$HAS_ATLASSTYLER" = 1 ] ; then
  # Add Geotools .fix and .qix files to all Shapefiles. Normally Geotools application would create these
  # files when opeing the Shapefile, but since the data-dir is read-only, we do it here.
  # This REQUIRES that install_atlasstyler.sh has been executed before (which is checked above)
  find "$NE2_DATA_FOLDER" -iname "*.shp" -exec atlasstyler "addFix={}" \;
else
  # Plan B: use ogrinfo instead
  cd "$NE2_DATA_FOLDER"
  for SHP in *.shp; do \
        S=`basename $SHP .shp`
        ogrinfo -sql "CREATE SPATIAL INDEX ON $S" $SHP;
  done
  cd "$TMP"
  # fixme: Is there a need to walk thru other folders as well??
fi

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
# 1/2013 Needed for Kosmo and gvSIG:
#sudo -u $POSTGRES_USER psql natural_earth2 \
#  -f /usr/share/postgresql/10/contrib/postgis-2.4/legacy.sql

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
BASE_URL="http://grass.osgeo.org/sampledata/north_carolina"

cd "$TMP"
mkdir -p nc_data
cd nc_data

mkdir -p "$DATA_FOLDER/north_carolina"


ln -s /usr/lib/python3/dist-packages/gisdata/data/good/raster/relief_san_andres.tif \
       $DATA_FOLDER/raster/relief_san_andres.tif

ln -s /usr/lib/python3/dist-packages/gisdata/data/good/raster/test_grid.tif \
      $DATA_FOLDER/raster/test_grid.tif


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

#### Updated North Carolina KML
# this dataset and website are no longer available
#DATA_URL="http://geofemengineering.it/osgeolive/"
#wget -N --progress=dot:mega "$DATA_URL/ossim_data/kml.tar.gz"
#tar xzf kml.tar.gz
#chown -R root.root kml/
#mv -f kml/* "$DATA_FOLDER"/north_carolina/kml/
#rm -rf kml/


# create overviews and histograms for OSSIM
OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference
export OSSIM_PREFS_FILE

# replace 32bit Landsat files with 8bit versions
#DATA_DIR="$DATA_FOLDER/north_carolina/rast_geotiff"

# this dataset are not found in the north_carolina/rast_geotiff directory

#for BAND in 10 20 30 40 50 61 62 70 80 ; do
#   BASENAME="lsat7_2002_$BAND.tif"
#   NEWNAME="lsat7_2002_${BAND}_8bit.tif"

#   /usr/bin/gdal_translate -ot Byte "$DATA_DIR/$BASENAME" "$DATA_DIR/$NEWNAME"
#   rm "$DATA_DIR/$BASENAME"
#   mv "$DATA_DIR/$NEWNAME" "$DATA_DIR/$BASENAME"

#   ossim-img2rr "$DATA_DIR/$BASENAME"
#   ossim-create-histo "$DATA_DIR/$BASENAME"
#done

/usr/bin/ossim-orthoigen --writer general_raster_bip \
   "$DATA_DIR/elevation.tif" \
   /usr/share/ossim/elevation/nc/elevation.ras

/usr/bin/ossim-orthoigen --writer general_raster_bip \
   "$DATA_DIR/elev_lid792_1m.tif" \
   /usr/share/ossim/elevation/lidar/elev_lid792_1m.ras


# add landsat and srtm dataset
cd $DATA_FOLDER
wget -N --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/landsat.tar.gz"
tar xzf landsat.tar.gz
chgrp users landsat
chmod g+w landsat
rm -rf landsat.tar.gz

# make srtm elevation
/usr/bin/ossim-orthoigen --writer general_raster_bip \
   "$DATA_FOLDER/landsat/srtm.tif" \
   /usr/share/ossim/elevation/srtm/srtm.ras

unset OSSIM_PREFS_FILE


chown -R root.root "$DATA_FOLDER"/north_carolina


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
