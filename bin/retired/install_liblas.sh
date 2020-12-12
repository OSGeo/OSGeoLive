#!/bin/sh
#############################################################################
#
# Purpose: This script will install libLAS
#
#############################################################################
# Copyright (c) 2013-2019 The Open Source Geospatial Foundation and others.
# Author:  Brian Hamlin dbb maplabs@light42.com
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo 'Installing libLAS ...'
apt-get install --yes liblas-bin python-liblas liblas3

# work-around for #1256 (remove this if liblas-c-dev pkg gets installed)
# ln -s /usr/lib/liblas_c.so.2.2.0 /usr/lib/liblas_c.so

echo 'Downloading demo data ...'
mkdir -p /usr/local/share/data/las
wget -c --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/liblas/srs.las" \
    -O /usr/local/share/data/las/srs.las

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
