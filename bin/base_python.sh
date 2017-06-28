#!/bin/sh
#############################################################################
#
# Purpose: This script will install Python development tools and libraries to use in
# OSGeoLive.
#
#############################################################################
# Copyright (c) 2016 Open Source Geospatial Foundation (OSGeo)
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

# Install Geospatial Python libraries
apt-get install --yes python-gdal python-shapely python-rasterio \
	python-fiona fiona rasterio python-matplotlib python-geopandas \
	python-netcdf4 python-geojson python-scipy python-pandas \
	python-pyshp python-descartes python-enum34 python-geographiclib

# Install Data-Science and Geospatial Python3 libraries
sudo apt-get install --yes \
python3-sqlalchemy \
python3-psycopg2 \
python3-geographiclib \
python3-fiona \
python3-rasterio \
rasterio \
python3-geopandas \
python3-shapely \
python3-geopy \
python3-owslib \
python3-geojson \
python3-netcdf4 \
python3-grib \
python3-matplotlib \
python3-pandas \
cython3 \
python3-patsy \
python3-h5py \
python3-numexpr \
python3-skimage-lib \
python3-setuptools 
python3-mpld3 \
python3-pygraphviz \
python3-seaborn \
python3-docutils \
python3-sklearn-pandas \
python3-feather-format \
python3-sphinx \
python3-tk \
python3-tables \
python3-sklearn \
python3-sympy \
python3-dill \
python3-pillow \
python3-arrow \
python3-pygeoif \
python3-pyproj \
python3-geopy 

"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
