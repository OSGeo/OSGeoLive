#!/bin/sh
#############################################################################
#
# Purpose: This script will install C development tools and libraries to use in
# OSGeoLive.
#
#############################################################################
# Copyright (c) 2016-2023 Open Source Geospatial Foundation (OSGeo) and others.
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`

apt-get -q update

# Install C development packages
apt-get install --yes build-essential cmake pkg-config

# Install OSGeo C stack libraries
apt-get install --yes libgdal32 gdal-bin proj-bin libgeos-c1v5 geotiff-bin

"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
