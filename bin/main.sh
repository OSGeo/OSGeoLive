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
# This is the master GISVM script which will build a GISVM from a base
# Xubuntu system, by calling a series of scripts for each package

# Running:
# =======
# sudo ./master.sh

# Customisation:
# =============
# You can customise the contents of the liveDVD by commenting out install
# scripts.


# Uninstall / Install all the base system packages: ssh, java, etc
# Set up configuration files
./setup.sh

# Mapserver
./install_mapserver.sh

# Geoserver
./install_geoserver.sh

