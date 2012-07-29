#!/bin/sh
# Copyright (c) 2010-2011 The Open Source Geospatial Foundation.
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
# This script will install GpsPrune in Ubuntu
# GpsPrune is an application for viewing and post-processing GPS data
# Homepage: http://activityworkshop.net/software/prune/
# 

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


#Add repositories

# it's in UbuntuGIS's unstable-ppa.
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get -q update
apt-get install --assume-yes gpsprune

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed!'
   exit 1
fi

cp /usr/share/applications/gpsprune.desktop "$USER_HOME/Desktop/"


