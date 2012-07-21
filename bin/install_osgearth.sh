#!/bin/bash
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
# This script will install osgearth in xubuntu
#
# osgEarth is a scalable terrain rendering toolkit for OpenSceneGraph
# http://osgearth.org/

# Running:
# =======
# sudo ./install_osgearth.sh

#Add repositories

wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get -q update
apt-get install --assume-yes osgearth osgearth-data openscenegraph

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

# pre-set the enviro var
cat << EOF > /etc/profile.d/osgearth.sh
OSG_FILE_PATH=/usr/share/osgearth
export OSG_FILE_PATH
EOF

# share data with the rest of the disc
mkdir -p /usr/local/share/data/raster
ln -s /usr/share/osgearth/data/world.tif \
      /usr/local/share/data/raster/

