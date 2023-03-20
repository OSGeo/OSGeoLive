#!/bin/sh
#############################################################################
#
# Purpose: This script will install Python development tools and libraries to use in
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

# # Install Django
apt-get install --yes python3-django

# # Hold Django version to avoid upgrades from upstream
# apt-mark hold python3-django

# Install Geospatial Python libraries
apt-get install --yes python3-gdal python3-shapely python3-rasterio rasterio \
    python3-fiona fiona python3-matplotlib python3-tk python3-geopandas \
    python3-netcdf4 python3-geojson python3-scipy python3-pandas \
    python3-pyshp python3-descartes python3-geographiclib \
    python3-cartopy python3-seaborn python3-networkx python3-branca \
    python3-rtree python3-folium python3-lark python3-mappyfile \
    python3-pysal python3-geoalchemy2 python3-datacube

# Add a symlink for rio
ln -s /usr/bin/rasterio /usr/local/bin/rio

"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
