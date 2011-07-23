#!/bin/bash
#
# Copyright (c) 2009-2010 The Open Source Geospatial Foundation.
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
# This script will install geomoose

# Running:
# =======
# sudo ./install_geomoose.sh


mkdir -p /tmp/build-geomoose

cd /tmp/build-geomoose

wget -c "http://www.geomoose.org/downloads/geomoose-2.4.tar.gz"

tar -xzvf geomoose-2.4.tar.gz

rm -rf /usr/local/geomoose

mkdir -p /usr/local/geomoose

cd /usr/local/geomoose

mv /tmp/build-geomoose/geomoose*/* .

./configure --with-url-path=/geomoose --with-temp-directory=/tmp --with-mapfile-root=/usr/local/geomoose/maps

ln -s /usr/local/geomoose/htdocs /var/www/geomoose
