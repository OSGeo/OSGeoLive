#!/bin/sh
# Copyright (c) 2013 Open Source Geospatial Foundation (OSGeo)
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


# # Need at least version 1.5 for PostGIS 2.0 support.
# DJVER="1.5.1"
# 
# # Prevent installation via apt since needed version is not available as deb.
# cat << EOF >> /etc/apt/preferences
# Package: python-django
# Pin: release *
# Pin-Priority: -1
# EOF
# 
# ## FIXME: please use/create python-<package>.deb; do not use PIP or easy_install
# apt-get --assume-yes install python-pip
#     
# pip install --upgrade Django=="$DJVER"

#Install packages
add-apt-repository -y ppa:geonode/release
#add-apt-repository -y ppa:geonode/unstable
#add-apt-repository -y ppa:geonode/testing
apt-get -q update
apt-get --assume-yes install python-django

####
./diskspace_probe.sh "`basename $0`" end
