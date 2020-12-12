#!/bin/sh
###############################################################
#
# Purpose: Installation of pgRouting on Ubuntu 11.04
# Authors: Anton Patrushev <anton@georepublic.de>
#          Daniel Kastl <daniel@georepublic.de>
#          Vicky Vergara <vicky@georepublic.de>
#
# Copyright (c) 2011-2020 Open Source Geospatial Foundation (OSGeo) and others.
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
OSM_FILE="/usr/local/share/data/osm/feature_city.osm.bz2"
OSM_DB="pgrouting"

apt-get update -qq

# Get the postgres version that is installed
PG_VERSION=$(grep -Po '(?<=PG_VERSION=)[^;]+' service_postgresql.sh)
PG_VERSION="${PG_VERSION%\"}"
PG_VERSION="${PG_VERSION#\"}"


# Install pgRouting packages
apt-get install -y -qq postgresql-${PG_VERSION}-pgrouting

if [ $? -ne 0 ] ; then
   echo 'ERROR: pgRouting Package install failed! Aborting.'
   exit 1
fi

# Install osm2pgrouting package
apt-get install -y -qq osm2pgrouting

# Create tmp folders
mkdir -p "$TMP" && cd "$TMP"

# create $OSM_DB database EXAMPLE
#  10.0 - the quickstart will guide a user through making the sample db
#    drop this sample, after confirming it works

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
fi

# Drop the created database
sudo -u "$USER_NAME" psql  -c "DROP database ""$OSM_DB"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
