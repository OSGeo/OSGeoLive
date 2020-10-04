#!/bin/sh
# Copyright (c) 2010-2020 The Open Source Geospatial Foundation and others.
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

# About:
# =====
# This script will install GpsPrune in Ubuntu
# GpsPrune is an application for viewing and post-processing GPS data
# Homepage: http://activityworkshop.net/software/prune/
# 

./diskspace_probe.sh "`basename $0`" begin
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

apt-get -q update
apt-get install --assume-yes gpsprune

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed!'
   exit 1
fi

cp /usr/share/applications/gpsprune.desktop "$USER_HOME/Desktop/"

echo 'Downloading demo data ...'
mkdir -p /usr/local/share/data/vector/gpx
wget -c --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/gpsprune/test_trk2.gpx" \
    -O /usr/local/share/data/vector/gpx/test_trk2.gpx

####
./diskspace_probe.sh "`basename $0`" end
