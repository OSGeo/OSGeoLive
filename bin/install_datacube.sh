#!/bin/sh
# Copyright (c) 2022 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
#
# This library is libre software; you can redistribute it and/or modify it
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
# This script will install core datacube python3

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_datacube"
BIN="/usr/local/bin"

apt-get install --yes python3-datacube python3-odc-geo python3-odc-stac

mkdir -p "$TMP"
cd "$TMP"

sudo -u $USER_NAME createdb  datacube
sudo -u $USER_NAME psql datacube -c 'create extension postgis'
sudo -u $USER_NAME psql datacube -c 'create extension hstore'

# reset
# rm -rf .config/datacube
# psql -c 'drop database datacube'

##-------------------------------------------------

DCONF=/home/${USER_NAME}/.config/datacube

mkdir -p ${DCONF}

export DATACUBE_CONFIG_PATH=${DCONF}/datacube.conf

#----------------------------------------------
cat << EOF > ${DCONF}/datacube.conf
[datacube]
db_database: datacube

# A blank host will use a local socket. Specify a hostname (such as localhost) to use TCP.
db_hostname:

# Credentials are optional: you might have other Postgres authentication configured.
# The default username otherwise is the current user id.
db_username: user
db_password: user
EOF

##---------------------------------------------

cat << EOF > ${DCONF}/landsat-clip.yml
name: clip_landsat
description: example ortho imagery
metadata_type: eo3

license: CC-BY-4.0

metadata:
  product:
    name: clip_landsat

storage:
  crs: EPSG:32619
  resolution:
    longitude: 28.497418829384827
    latitude: -28.503958771796388

measurements:
  - name: imagery
    dtype: uint8
    nodata: -32768.0
    units: "metre"

EOF

##-------------------------------------------------

datacube -v system init

datacube product add ${DCONF}/landsat-clip.yml


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
