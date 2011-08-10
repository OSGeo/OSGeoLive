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

LIBLAS_REV="libLAS-1.7.0b2"
LASZIP_REV="laszip-2.0.1"

##-----------------------------------------------------
## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
mkdir -p "$TMP"
cd "$TMP"

# install pre-requisites
apt-get install --yes cmake
apt-get install --yes libboost1.42-dev libboost-program-options-dev \
   libboost-thread1.42-dev libboost-serialization1.42-dev libgdal1-1.8.0 \
   libgdal-dev libgeotiff-dev libgeotiff2

# get libLAS
wget -c --progress=dot:mega http://download.osgeo.org/liblas/$LIBLAS_REV.tar.gz
wget -c --progress=dot:mega http://download.osgeo.org/laszip/$LASZIP_REV.tar.gz

# unpack it
tar xzf $LIBLAS_REV.tar.gz
tar xzf $LASZIP_REV.tar.gz

if [ $? -ne 0 ] ; then
   echo "ERROR: libLAS download failed."
   exit 1
fi

##--------------------------------------
## begin build

cd $LASZIP_REV
# fixme: please install to /usr/local/
cmake -G "Unix Makefiles" . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release

##--------------------------------------
make
if [ $? -ne 0 ] ; then
   echo "ERROR: laszip make failed."
   exit 1
fi

make install
if [ $? -ne 0 ] ; then
   echo "ERROR: laszip install failed."
   exit 1
fi

ldconfig

##--------------------------------------
cd ../$LIBLAS_REV
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

##-----------------------------------
## build - check status...
make
if [ $? -ne 0 ] ; then
   echo "ERROR: libLAS make failed."
   exit 1
fi

##
make install
if [ $? -ne 0 ] ; then
   echo "ERROR: libLAS install failed."
   exit 1
fi

##
ldconfig

## Python libraries ##
cd ../python
python setup.py build
python setup.py install


## Shared Resources ##
mkdir -p "$LIBLAS_FOLDER"
mkdir -p "$LIBLAS_FOLDER/python"

cp -R examples scripts tests  "$LIBLAS_FOLDER/python/"

cd ..
cp -R doc "$LIBLAS_FOLDER/"
cp -R test "$LIBLAS_FOLDER/"
cp LICENSE.txt NEWS README.txt "$LIBLAS_FOLDER/"


##------------------------------------------------------------
## cleanup dev packages
##   make sure these stay installed
apt-get --yes install libboost-date-time1.42.0 \
   libboost-program-options1.42.0 libboost-serialization1.42.0

# note - cmake is cleaned up by setdown.sh
apt-get --yes remove libboost1.42-dev libboost-program-options-dev \
   libboost-thread1.42-dev libboost-serialization1.42-dev \
   libgdal-dev libgeotiff-dev

echo "FIXME: make sure we haven't lost any important automatically installed pkgs"


