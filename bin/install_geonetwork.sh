#!/bin/sh
#################################################
# 
# Purpose: Installation of GeoNetwork into Lubuntu
# Author:  Ricardo Pinho <ricardo.pinho@gisvm.com>
# Author:  Simon Pigot <simon.pigot@csiro.au>
# Author:  Francois Prunayre <fx.prunayre@gmail.com>
# Small edits: Jeroen Ticheler <Jeroen.Ticheler@GeoCat.net>
#
#################################################
# Copyright (c) 2010-2026 Open Source Geospatial Foundation (OSGeo) and others.
# Copyright (c) 2009 GISVM.COM
#
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
##################################################
#
# About:
# =====
# This script will install geonetwork into OSGeo live using docker
# stable version: v3.12.12
# based on Docker + GeoNetwork + H2
# Port number = 8880
#
# To start geonetwork
# docker start geonetwork
#
# To stop geonetwork
# docker stop geonetwork
#
# To enter geonetwork, start browser with url:
# http://localhost:8880/geonetwork

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

docker pull geonetwork:3.12.12
docker run --name geonetwork -d -p 8880:8080 geonetwork:3.12.12
docker stop geonetwork

# create startup, shutdown, open browser and doc desktop entries
for FILE in start_geonetwork stop_geonetwork geonetwork ; do
   cp -f -v "$BUILD_DIR/../app-conf/geonetwork/$FILE.desktop" .
   cp -f "$FILE.desktop" "$USER_HOME/Desktop/$FILE.desktop"
   chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/$FILE.desktop"
done

#copy project logo to use as menu icon
cd "$TMP"
wget -c --progress=dot:mega \
 "https://github.com/OSGeo/OSGeoLive-doc/raw/master/doc/images/projects/geonetwork/logo_geonetwork.png" \
 -O geonetwork_icon.png
mkdir -p /usr/local/share/icons
mv geonetwork_icon.png /usr/local/share/icons/geonetwork_icon.png

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
