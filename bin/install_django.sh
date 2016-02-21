#!/bin/sh
# Copyright (c) 2013-2016 Open Source Geospatial Foundation (OSGeo)
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
# This script installs Django.

./diskspace_probe.sh "`basename $0`" begin
####

#Install packages
#add-apt-repository -y ppa:geonode/release
apt-get -q update
apt-get --assume-yes install python-django
#apt-add-repository --yes --remove ppa:geonode/release

####
./diskspace_probe.sh "`basename $0`" end
