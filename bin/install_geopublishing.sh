#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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

# Author: Stefan A. Krüger

# About:
# =====
# This script will install the geopublishing.deb which contains the AtlasStyler SLD editor and the Geopublisher application

# Running:
# =======
# "atlasstyler" or "geopublisher" or Application -> Science -> Geopublisher/AtlasStyler

# Requirements:
# =======
# Latest Sun JRE 1.6 

# Get the sources list file (may overwrite existing sources file, but that is no problem)
# Uses lsb_release so that the script will run unchanged for "lucid" and later versions of ubuntu/debian
apt-get install --yes lsb-release
wget -nv --output-document="/etc/apt/sources.list.d/geopublishing.list" \
   "http://www.geopublishing.org/sources.list.d/$(lsb_release -cs).list"

# Get and import the key that the .deb packages are signed with
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD

# Install Geopublisher and AtlasStyler and documentation
apt-get update --yes
apt-get install --yes --no-install-recommends geopublishing geopublishing-doc
