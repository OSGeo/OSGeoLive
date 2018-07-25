#!/bin/sh
#############################################################################
#
# Purpose: This script will install Python development tools and libraries to use in
# OSGeoLive.
#
#############################################################################
# Copyright (c) 2016-2018 Open Source Geospatial Foundation (OSGeo) and others.
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

# install the python .deb maker
apt-get install --yes python-all-dev
# removed from list: python-stdeb

# Install Django
apt-get install --yes python-django

# Hold Django version to avoid upgrades from upstream
#apt-mark hold python-django

# Install Geospatial Python2 libraries
apt-get install --yes python-gdal python-shapely python-rasterio \
	python-fiona python-matplotlib python-geopandas python-pysal \
	python-netcdf4 python-geojson python-scipy python-pandas \
	python-pyshp python-descartes python-geographiclib python-kml \
	python-cartopy python-seaborn

# Install Geospatial Python3 libraries
apt-get install --yes python3-gdal fiona rasterio

"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
