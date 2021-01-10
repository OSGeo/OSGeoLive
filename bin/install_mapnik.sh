#!/bin/sh
#############################################################################
#
# Purpose: This script will install Mapnik library and Python bindings
# for a demo 'World Borders' application
#
#############################################################################
# Copyright (c) 2009-2020 The Open Source Geospatial Foundation and others.
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
#############################################################################

#
# Requires:
# =========
# python, wget, unzip
#
# Uninstall:
# ==========
# sudo apt-get remove python-mapnik
# rm -rf /usr/local/share/mapnik/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp/build_mapnik"
DATA_FOLDER="/usr/local/share"
MAPNIK_DATA="$DATA_FOLDER/mapnik"
BIN="/usr/local/bin"

apt-get install --yes python3-mapnik

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

if [ ! -d "$MAPNIK_DATA" ] ; then
   echo "Creating $MAPNIK_DATA directory"
   mkdir -p "$MAPNIK_DATA"
fi

chmod -R 755 "$MAPNIK_DATA"
sudo cp -f "$BUILD_DIR/../app-conf/mapnik/world_population.xml" \
    "$MAPNIK_DATA/world_population.xml"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
