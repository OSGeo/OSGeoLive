#!/bin/sh
###############################################################
#
# Purpose: Installation of pgRouting on Ubuntu 11.04
# Authors: Anton Patrushev <anton@georepublic.de>
#          Daniel Kastl <daniel@georepublic.de>
#
# Copyright (c) 2011-2016 Open Source Geospatial Foundation (OSGeo)
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
#
# About:
# =====
# This script will install the following software
#       - pgRouting library
#       - osm2pgrouting converter
#       - pgRouting workshop
#
# NOTE: To make use of OSM sample data "install_osm.sh" should be run first  
#       Import of OSM sample data and converter can take some time   

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_pgrouting"
OSM_FILE="/usr/local/share/data/osm/feature_city_CBD.osm.bz2"
OSM_DB="pgrouting"

# Add pgRouting launchpad repository
# TODO: switch from "unstable" to "stable" when repository is updated

# TODO: Remove third party PPAs
#add-apt-repository -y ppa:georepublic/pgrouting
apt-get update -qq

# Install pgRouting packages
apt-get install -y -qq postgresql-9.5-pgrouting
	
if [ $? -ne 0 ] ; then
   echo 'ERROR: pgRouting Package install failed! Aborting.'
   exit 1
fi

# Install osm2pgrouting package
apt-get install -y -qq osm2pgrouting

# Install workshop material
# TODO: not packaged yet
#apt-get install -y -qq pgrouting-workshop

# Create tmp folders
mkdir -p "$TMP" && cd "$TMP"

# create $OSM_DB database
echo "create $OSM_DB database with PostGIS and pgRouting"
sudo -u "$USER_NAME" createdb -E UTF8 "$OSM_DB"
sudo -u "$USER_NAME" psql "$OSM_DB" -c 'CREATE EXTENSION postgis;'
sudo -u "$USER_NAME" psql "$OSM_DB" -c 'CREATE EXTENSION pgrouting;'

# Process sample data that comes with "install_osm.sh"
if [ ! -e "$OSM_FILE" ] ; then
	echo "ERROR: $OSM_FILE sample data is not available"
	exit 1
else
	# unpack sample data
	echo "unpack sample data"
	bunzip2 "$OSM_FILE" -c > "$TMP/sampledata.osm"

	# Run osm2pgrouting converter
	# NOTE: Conversion can take a a few minutes depending on the extent of the sample data.
	# Assuming that the sample data won't be very big, it should be OK to run the conversion here, 
	# otherwise it should be done in advance somehow (TODO).
	echo "Run osm2pgrouting converter (this may take a while)"
	sudo -u $USER_NAME osm2pgrouting -file "$TMP/sampledata.osm" \
	    -conf /usr/share/osm2pgrouting/mapconfig.xml \
	    -dbname "$OSM_DB" \
	    -user "$USER_NAME" \
	    -host localhost \
	    -clean \
	  > pgrouting_import.log

	sudo -u "$USER_NAME" psql "$OSM_DB" -c "VACUUM ANALYZE;"
fi

# NOTE: the following is going to change with the updated workshop
#### recenter the workshop demo on the OSM_local database
#LONG_LAT="-1.147 52.954"   # Nottingham CBD

#GOOG_SMERC="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 \
#   +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"

# reproject lat/long to Google's funny smerc (epsg:900913)
#EN=`echo "$LONG_LAT" | cs2cs +proj=longlat +datum=WGS84 +to $GOOG_SMERC | awk '{printf("%.0f, %.0f", $1, $2)}'`

# set as 'center: [x, y],' in OpenLayers demo
#sed -i -e "s|center: \[.*\]|center: \[$EN\]|" \
#       -e 's|zoom: 12,|zoom: 14,|' \
#  /usr/share/pgrouting/workshop/web/routing-*.html

# adjust DB and user name in workshop example
#sed -i -e 's|"routing"|"pgrouting"|' \
#       -e 's|"postgres"|"user"|' \
#  /usr/share/pgrouting/workshop/web/php/pgrouting.php

# symlink it into a served dir so the php will run
#ln -s /usr/share/pgrouting/workshop/web /var/www/html/pgrouting

# to get the routing-final.html demo working you'll still need to set
# the IPv4 host pgsql permissions to 'trust' in pg_hpa.conf. but we
# don't want to do that by default.

#add-apt-repository -y --remove ppa:georepublic/pgrouting

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
