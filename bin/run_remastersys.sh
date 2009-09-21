#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will create a bootable iso from the current running system

# Running:
# Note: Run this absolutely last, especially after doing filesystem cleanup
# =======
# sudo ./run_remastersys.sh
#


DIR=`dirname ${0}`
VERSION=`cat ${DIR}/../VERSION.txt`
PACKAGE_NAME="arramagong-livedvd"
ISO_NAME="${PACKAGE_NAME}-${VERSION}"
TMP="/tmp/build_remastersys"
LOGS="/var/log/arramagong/remastersys.conf"

#Install remastersys.sh
mkdir -p $TMP
cd $TMP
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/remastersys.list \
     --output-document=/etc/apt/sources.list.d/remastersys.list

# apt-get update
apt-get --assume-yes install remastersys

#Configure
#ie set exclude folders in /etc/remastersys.conf
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/remastersys.conf \
     --output-document=$LOG

#quick name check
echo "Now creating ${ISO_NAME}.iso"

#Create iso, only uncomment once it's working
sudo remastersys backup ${ISO_NAME}.iso

