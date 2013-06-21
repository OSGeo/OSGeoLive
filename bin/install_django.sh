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

# Running:
# =======
# sudo ./install_django.sh

SCRIPT="install_django.sh"
echo "==============================================================="
echo "$SCRIPT"
echo "==============================================================="

echo "Starting Django installation"

# Need at least version 1.5 for PostGIS 2.0 support.
DJVER="1.5.1"

apt-get --assume-yes install python-pip
    
pip install --upgrade Django=="$DJVER"

echo "==============================================================="
echo "Finished $SCRIPT"
echo Disk Usage1:, $SCRIPT, `df . -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, $SCRIPT, `df . -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
echo "==============================================================="
