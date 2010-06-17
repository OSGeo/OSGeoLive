#!/bin/sh
######################################################
# 
# Purpose: Installation of pgRouting on Xubuntu 9.04
# Author:  Anton Patrushev <anton.patrushev@gmail.com>
#
######################################################
# Copyright (c) 2009 Open Source Geospatial Foundation (OSGeo)
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
# This script will install pgRouting into Xubuntu 

# Running:
# =======
# sudo ./install_pgrouting.sh

TMP="/tmp/pgrouting_downloads"
INSTALL_FOLDER="$TMP/pgrouting"
POSTGIS_FOLDER="/usr/share/postgresql-8.3-postgis"
POSTLBS_FOLDER="/usr/share/postlbs"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
LOGS="/var/log/pgrouting.log"
## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
 echo "ERROR: wget is required, please install it and try again" 
 exit 1
fi

if [ ! -x "`which psql`" ] ; then
 echo "ERROR: PostgreSQL is required, please install it and try again" 
 exit 1
fi

# create tmp folders
mkdir "$TMP"
cd "$TMP"

# install libraries
apt-get install --yes \
   postgresql-server-dev-8.3 \
   build-essential \
   cmake \
   libboost1.35-dev \
   libboost-graph1.35-dev \
   libcgal*

echo "FIXME: remove -dev packages once you are done with them. libboost-dev is hundreds of MB."
# Explicitly set which ones you want to keep for runtime 
#    otherwise there is a good chance they will be auto-cleaned:
# (prior apt-get installs these, this one is just to remove the auto-tag)
apt-get install --yes libcgal2 libqt3-mt \
   libboost-date-time1.35.0 libboost-filesystem1.35.0 \
   libboost-graph1.35.0 libboost-iostreams1.35.0 \
   libboost-program-options1.35.0 libboost-python1.35.0 \
   libboost-regex1.35.0 libboost-serialization1.35.0 \
   libboost-signals1.35.0 libboost-system1.35.0 \
   libboost-test1.35.0 libboost-thread1.35.0 \
   libboost-wave1.35.0 libgmpxx4ldbl


if [ -f "gaul-devel-0.1849-0.tar.gz" ]
then
 echo "gaul-devel-0.1849-0.tar.gz has already been downloaded."
else
 wget -c "http://downloads.sourceforge.net/gaul/gaul-devel-0.1849-0.tar.gz?modtime=1114163427&big_mirror=0"
fi

tar -xzf gaul-devel-0.1849-0.tar.gz
cd gaul-devel-0.1849-0/

./configure --disable-slang

make
sudo make install
sudo ldconfig

cd "$TMP"

# get pgRouting
if [ -f "pgRouting-1.03.tgz" ]
then
 echo "pgRouting-1.03.tgz has already been downloaded."
else
 wget -c http://files.postlbs.org/pgrouting/source/pgRouting-1.03.tgz
fi

# get sample data
if [ -f "sydney.tar.gz" ]
then
 echo "sydney.tar.gz has already been downloaded."
else
 wget --progress=dot:mega http://files.postlbs.org/foss4g2009/sydney.tar.gz
fi

# unpack sample data
tar -xzf sydney.tar.gz -C "$TMP"

# unpack and compile pgRouting
tar -xzf pgRouting-1.03.tgz -C "$TMP"

cd "$INSTALL_FOLDER"

cmake -DWITH_TSP=ON -DWITH_DD=ON .
make
# we are already root
make install

# create routing database
sudo -u $USER_NAME createdb sydney
sudo -u $USER_NAME createlang plpgsql sydney

cd ..

# add PostGIS functions
sudo -u $USER_NAME psql -f $POSTGIS_FOLDER/lwpostgis.sql sydney
sudo -u $USER_NAME psql -f $POSTGIS_FOLDER/spatial_ref_sys.sql sydney

# add pgRouting functions
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_core.sql sydney
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_core_wrappers.sql sydney
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_topology.sql sydney

# add pgRouting TSP functions
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_tsp.sql sydney
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_tsp_wrappers.sql sydney

# add pgRouting Driving Distance functions
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_dd.sql sydney
sudo -u $USER_NAME psql -f $POSTLBS_FOLDER/routing_dd_wrappers.sql sydney

# add data to the database
sudo -u $USER_NAME psql -c "DROP TABLE geometry_columns"  sydney
sudo -u $USER_NAME psql --quiet -f schema.sql  sydney
sudo -u $USER_NAME psql --quiet -f sydney.sql  sydney

# testing pgRouting functions
# Renable once we figure out how to get rid of user interaction
sudo -u $USER_NAME psql -c "SELECT gid, AsText(the_geom) AS the_geom FROM dijkstra_sp_delta('sydney', 101, 114, 0.003)"  sydney
sudo -u $USER_NAME psql -c "SELECT gid, AsText(the_geom) AS the_geom FROM astar_sp_delta('sydney', 101, 114, 0.003)"  sydney
sudo -u $USER_NAME psql -c "SELECT gid, AsText(the_geom) AS the_geom FROM shootingstar_sp('sydney', 8, 24, 0.1, 'length', true, true)"  sydney
