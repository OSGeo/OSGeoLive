#!/bin/sh
# Copyright (c) 2010-2018 The Open Source Geospatial Foundation and others.
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
# This script will install the zyGrib viewer (1.4mb installed)

./diskspace_probe.sh "`basename $0`" begin
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

apt-get --assume-yes install zygrib

# zygrib-maps package is 8.6mb (contains NOAA's GSHHS coastline)

# copy icon to Desktop
cp /usr/share/applications/zygrib.desktop \
   "$USER_HOME/Desktop/zygrib.desktop"

# de-uppercase the executable
ln -s /usr/bin/zyGrib /usr/local/bin/zygrib


####
./diskspace_probe.sh "`basename $0`" end
