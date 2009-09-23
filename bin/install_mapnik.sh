#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# About:
# =====
# This script will install Mapnik library and Python bindings
# and TileLite for a demo 'World Borders' application
#
# Running:
# =======
# sudo ./install_mapnik.sh

# will fetch Mapnik 0.5.1 on Ubuntu 9.04
apt-get install --yes python-mapnik


# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp"
DATA_FOLDER="/usr/local/share"

cd $TMP

## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

if [ ! -d $DATA_FOLDER/mapnik ]
then
    echo "Create $DATA_FOLDER/mapnik directory"
    mkdir $DATA_FOLDER/mapnik
fi

# download TileLite sources
wget -c http://bitbucket.org/springmeyer/tilelite/get/tip.zip
unzip -o tip.zip
rm tip.zip
cd $TMP/tilelite


# using the standard python installation tools
python setup.py install # will install 'tilelite.py' in site-packages and 'liteserv.py' in default bin directory

# copy TileLite demo application and data to 'mapnik' subfolder of DATA_FOLDER
cp demo $DATA_FOLDER/mapnik -R

# now get rid of temporary unzipped sources
rm -fr $TMP/tilelite

# then to run demo do...
#cd $DATA_FOLDER/mapnik

# lauch the tile server with a Mapnik XML mapfile as input
#liteserv.py demo/population.xml

# Note on the above command which launchs server.
# The paths in XML mapfile depend on the demo being run from this exact spot,
# so users must either edit the shapefile path inside 'population.xml' or make sure to
# run from '$DATA_FOLDER/mapnik'


## MANUAL STEPS ##

# View the server homepage:
# open in a browser...
# http://yourdomain.com:8000 or http://localhost:8000

# Then view the tiles in sample OpenLayers Map (needs internet connection for OpenLayers.js, etc)
# file:///usr/local/share/mapnik/demo/openlayers.html
