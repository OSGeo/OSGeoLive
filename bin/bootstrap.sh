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
# This script provides the steps to be run on the LiveDVD in order to get the
# install scripts onto the LiveDVD, and start installing.

# Running:
# =======
# sudo ./boostrap.sh

# Copy tmp download files for faster downloading

apt-get install subversion
cd /usr/local/bin
svn co http://svn.osgeo.org/osgeo/livedvd/gisvm
chown -R user:user gisvm
cd ~
ln -s /usr/local/bin/gisvm .

