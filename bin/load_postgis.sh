#!/bin/sh
# Copyright (c) 2009 Mark Leslie
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
# About:
# =====
# This script will is to be run after the installation of postgresql 
# and postgis.  It will download, validate and load a simple dataset.
#
# Authors:
# =======
# Alex Mandel <tech@wildintellect.com>
# Brian Hamlin <maplabs-at-light42-dot-com>
# Hamish Bowman <hamish_b yahoo com>
# Mark Leslie <mark.s.leslie@gmail.com>
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

POSTGRES_USER="$USER_NAME"
TMP_DIR="/tmp/build_postgis"

if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


### download data
## May12  - standardize data file name
## July10 - rely on a reference download of OSM data
##  provided by ** install_osm.sh **, instead of getting it here
##  File name will change from time to time.

#CITY=""
OSM_FILE="/usr/local/share/data/osm/feature_city.osm.bz2"

# download package is not versioned so we really shouldn't use "wget -c"
#wget -c --progress=dot:mega "$URL_BASE/$DL_FILE"
# -O used to enable auto-overwrite
#wget -nv "$URL_BASE/$DL_FILE.sha1" -O "$DL_FILE.sha1"

#sha1sum --check "$DL_FILE.sha1"
#if [ $? -ne 0 ] ; then
#   echo "ERROR: checksum failed on download"
#   exit 1
#fi

### create DB and populate it
###  PostGIS 2.0 no longer needs a template, use the extension mechanism instead
sudo -u $POSTGRES_USER createdb osm_local
sudo -u $POSTGRES_USER psql osm_local -c 'create extension postgis;'


# Kosmo, gpsdrive, please update your API calls ....
#cp "$BUILD_DIR"/../app-conf/postgis/legacy*.sql \
#  /usr/share/postgresql/9.5/contrib/postgis-2.2/
#
#sed -i -e 's/postgis-2.0/postgis-2.2/' \
#  /usr/share/postgresql/9.5/contrib/postgis-2.2/legacy*.sql
#
#sudo -u $POSTGRES_USER psql osm_local \
#  -f /usr/share/postgresql/9.5/contrib/postgis-2.2/legacy_minimal.sql

#sudo -u $POSTGRES_USER createdb osm_local_smerc
#sudo -u $POSTGRES_USER psql osm_local_smerc -c 'create extension postgis;'
#sudo -u $POSTGRES_USER psql osm_local_smerc \
#  -f /usr/share/postgresql/9.3/contrib/postgis-2.1/legacy_minimal.sql

# v3 - simplified the script, was too hard to debug with all the commands
#  attempting to be piped continuously with each other
#bzip2 -d "$DL_FILE"
#sed -i "s/mleslie/$POSTGRES_USER/g" `basename $DL_FILE .bz2`
# use the psql --quiet flag!
#sudo -u $POSTGRES_USER psql --quiet -d denver -f `basename $DL_FILE .bz2`

## July10 - 
##   Now importing data from already downloaded sources (osm)

if [ ! -e "$OSM_FILE" ] ; then
    echo "ERROR: $OSM_FILE sample data is not available"
    exit 1
fi

# lat/lon
sudo -u $POSTGRES_USER osm2pgsql -U $POSTGRES_USER \
     --database osm_local --latlong \
     --style /usr/share/osm2pgsql/default.style \
     "$OSM_FILE"

sudo -u $POSTGRES_USER psql osm_local \
     --quiet -c "vacuum analyze"


# spherical merc
#sudo -u $POSTGRES_USER osm2pgsql -U $POSTGRES_USER \
#     --database osm_local_smerc --merc \
#     --style /usr/share/osm2pgsql/default.style \
#     /usr/local/share/osm/$CITY.osm.bz2
#
#sudo -u $POSTGRES_USER psql osm_local_smerc \
#     --quiet -c "vacuum analyze"


#Add additional data sources here, be sparing to minimize duplication of data.


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
