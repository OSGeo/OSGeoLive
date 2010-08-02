#!/bin/sh
###############################################################
# 
# Purpose: Installation of pgRouting on Ubuntu 10.04
# Authors: Anton Patrushev <anton.patrushev@georepublic.de>
#          Daniel Kastl <daniel.kastl@georepublic.de>
#
###############################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
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

# Running:
# =======
# sudo ./install_pgrouting.sh

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_pgrouting"
OSM_FILE="/usr/local/share/osm/Barcelona.osm.bz2"
OSM_DB="pgrouting"

POSTGIS_VERSION="8.4"
POSTLBS_FOLDER="/usr/share/postlbs"

# PostGIS 1.4
#POSTGIS_FOLDER="/usr/share/postgresql/$POSTGIS_VERSION/contrib/"

# PostGIS 1.5
POSTGIS_FOLDER="/usr/share/postgresql/$POSTGIS_VERSION/contrib/postgis-1.5/"

# Add pgRouting launchpad repository
add-apt-repository ppa:georepublic/pgrouting
apt-get update

# Install pgRouting packages
apt-get --assume-yes install gaul-devel \
	postgresql-8.4-pgrouting \
	postgresql-8.4-pgrouting-dd \
	postgresql-8.4-pgrouting-tsp
	
if [ $? -ne 0 ] ; then
   echo 'ERROR: pgRouting Package install failed! Aborting.'
   exit 1
fi

# Install osm2pgrouting package
apt-get --assume-yes install osm2pgrouting

# Install workshop material
apt-get --assume-yes install pgrouting-workshop

# Create tmp folders
mkdir "$TMP"
cd "$TMP"

# create $OSM_DB database
echo "create $OSM_DB database"
sudo -u $USER_NAME createdb $OSM_DB
sudo -u $USER_NAME createlang plpgsql $OSM_DB

# add PostGIS functions
echo "add PostGIS functions"
sudo -u $USER_NAME psql --quiet -f $POSTGIS_FOLDER/postgis.sql $OSM_DB
sudo -u $USER_NAME psql --quiet -f $POSTGIS_FOLDER/spatial_ref_sys.sql $OSM_DB

# add pgRouting core functions
echo "add pgRouting core functions"
sudo -u $USER_NAME psql --quiet -f $POSTLBS_FOLDER/routing_core.sql $OSM_DB
sudo -u $USER_NAME psql --quiet -f $POSTLBS_FOLDER/routing_core_wrappers.sql $OSM_DB
sudo -u $USER_NAME psql --quiet -f $POSTLBS_FOLDER/routing_topology.sql $OSM_DB

# add pgRouting TSP functions
echo "add pgRouting TSP functions"
sudo -u $USER_NAME psql --quiet -f $POSTLBS_FOLDER/routing_tsp.sql $OSM_DB
sudo -u $USER_NAME psql --quiet -f $POSTLBS_FOLDER/routing_tsp_wrappers.sql $OSM_DB

# TODO: add pgRouting Driving Distance functions
#echo "add pgRouting Driving Distance functions"
#sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_dd.sql $OSM_DB
#sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_dd_wrappers.sql $OSM_DB

# Process sample data that comes with "install_osm.sh"
if [ ! -e "$OSM_FILE" ]
then
	echo "ERROR: $OSM_FILE sample data is not available"
	exit 1
else
	# unpack sample data
	echo "unpack sample data"
	bunzip2 $OSM_FILE -c > "$TMP/sampledata.osm"

	# Run osm2pgrouting converter
	# NOTE: Conversion can take a a few minutes depending on the extent of the sample data.
	# Assuming that the sample data won't be very big, it should be OK to run the conversion here, 
	# otherwise it should be done in advance somehow (TODO).
	echo "Run osm2pgrouting converter (this may take a while)"
	sudo -u $USER_NAME osm2pgrouting -file "$TMP/sampledata.osm" \
	    -conf usr/share/osm2pgrouting/mapconfig.xml \
	    -dbname $OSM_DB \
	    -user $USER_NAME \
	    -host localhost \
	    -clean

	# Simple pgRouting test queries
	# Renable once we figure out how to get rid of user interaction
	#psql -U $USER_NAME -c "SELECT gid, AsText(the_geom) AS the_geom FROM dijkstra_sp_delta('ways', 1, 20, 0.003)"  $OSM_DB
	#psql -U $USER_NAME -c "SELECT gid, AsText(the_geom) AS the_geom FROM astar_sp_delta('ways', 1, 20, 0.003)"  $OSM_DB
	#psql -U $USER_NAME -c "SELECT gid, AsText(the_geom) AS the_geom FROM shootingstar_sp('ways', 1, 20, 0.1, 'length', true, true)"  $OSM_DB
fi

echo "Finished installing pgRouting and pgRouting tools."
