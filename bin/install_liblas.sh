#!/bin/sh
#################################################
# 
# Purpose: Install libLAS 
# Author:  Brian Hamlin dbb maplabs@light42.com
#
#################################################
# Copyright (c) 2011 Open Source Geospatial Foundation (OSGeo)
#
# Licensed under the GNU GPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, either
# in the "LICENSE.GPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/gpl.html".
##################################################

# About:
# =====
# This script will build and install libLAS into Xubuntu

# Running:
# =======
# sudo ./install_liblas.sh

USER_NAME="user"
TMP="/tmp/build_libLAS"
INSTALL_FOLDER="/usr/local/share"
LIBLAS_FOLDER="$INSTALL_FOLDER/libLAS"
BIN="/usr/local/bin"
USER_HOME="/home/$USER_NAME"

## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir $TMP
cd $TMP

## Install ##

# install pre-requisites
apt-get install --yes cmake
apt-get install --yes libboost1.42-dev libboost-program-options-dev libboost-thread1.42-dev libboost-serialization1.42-dev libgdal1-1.8.0 libgdal-dev libgeotiff-dev libgeotiff2

# get libLAS
wget -c --progress=dot:mega http://download.osgeo.org/liblas/libLAS-1.7.0b2.tar.gz
wget -c --progress=dot:mega http://download.osgeo.org/laszip/laszip-2.0.1.tar.gz

# unpack it
tar xzf laszip-2.0.1.tar.gz
tar xzf libLAS-1.7.0b2.tar.gz

if [ $? -ne 0 ] ; then
   echo "ERROR: libLAS download failed."
   exit 1
fi

cd laszip-2.0.1
cmake -G "Unix Makefiles" . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make
make install
ldconfig

cd ../libLAS-1.7.0b2
mkdir makefiles
cd makefiles

## execute cmake script
cmake -G "Unix Makefiles" ../ \
        -DBoost_INCLUDE_DIR=/usr/include \
        -DBoost_LIBRARY_DIRS=/usr/lib \
        -DGDAL_CONFIG=/usr/bin/gdal-config \
        -DGEOTIFF_INCLUDE_DIR=/usr/include/geotiff \
        -DGEOTIFF_LIBRARY=/usr/lib/libgeotiff.so \
        -DLASZIP_INCLUDE=/usr/include/laszip \
        -DLASZIP_LIBRARY=/usr/lib/liblaszip.so \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_GDAL=ON \
        -DWITH_GEOTIFF=ON \
        -DWITH_LASZIP=ON


## build  TODO check status...
make

## 
make install

##
ldconfig

## Python libraries ##
cd ../python
python setup.py build
python setup.py install


## Shared Resources ##
mkdir -p $LIBLAS_FOLDER
mkdir -p $LIBLAS_FOLDER/python

cp -R examples scripts tests  $LIBLAS_FOLDER/python/

cd ..
cp -R doc $LIBLAS_FOLDER/
cp -R test $LIBLAS_FOLDER/
cp LICENSE.txt NEWS README.txt $LIBLAS_FOLDER/


