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
INSTALL_FOLDER="/usr/local/lib"
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
apt-get install --yes libboost1.42-dev libboost-program-options-dev libboost-thread1.42-dev libboost-serialization1.42-dev

# get libLAS
wget -c --progress=dot:mega http://download.osgeo.org/liblas/libLAS-1.6.1.tar.gz

# unpack it
tar xzf libLAS-1.6.1.tar.gz

if [ $? -ne 0 ] ; then
   echo "ERROR: libLAS download failed."
   exit 1
fi

cd libLAS-1.6.1
mkdir makefiles
cd makefiles

## execute cmake script
cmake -G "Unix Makefiles" ../

## build  check status...
make

## 
make install

##
ldconfig

