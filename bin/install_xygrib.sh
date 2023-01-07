#!/bin/sh
# Copyright (c) 2010-2023 The Open Source Geospatial Foundation and others.
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
# This script will install the xyGrib viewer (1.4mb installed)

./diskspace_probe.sh "`basename $0`" begin
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

apt-get --assume-yes install xygrib

# zygrib-maps package is 170mb (contains NOAA's GSHHS coastline)
# rm /usr/share/maps/gshhs/gshhs_0.rim
# rm /usr/share/maps/gshhs/gshhs_1.rim
# rm /usr/share/maps/gshhs/wdb_rivers_f.b

# copy icon to Desktop
cp /usr/share/applications/xygrib.desktop \
   "$USER_HOME/Desktop/xygrib.desktop"

# de-uppercase the executable
ln -s /usr/bin/XyGrib /usr/local/bin/xygrib


####
./diskspace_probe.sh "`basename $0`" end
