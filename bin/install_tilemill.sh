#!/bin/sh
# Copyright (c) 2012 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install TileMill
#    this script authored by H.Bowman <hamish_b  yahoo com> (if you can call it that)
#    homepage: http://mapbox.com/tilemill

# Need to get 68.4 MB of archives.
# After this operation, 186 MB of additional disk space will be used.


add-apt-repository --yes ppa:developmentseed/mapbox

apt-get -q update

apt-get --assume-yes install tilemill


