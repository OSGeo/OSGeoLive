#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
#
# This script is free software; you can redistribute it and/or modify it
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
# This script will install the OpenCpn GPS navigation software
#    written by H.Bowman <hamish_b  yahoo com>
#    OpenCpn homepage: http://www.opencpn.org/
#    OpenCpn license: GPL
#
# Description: OpenCPN is an OpenSource Chart PLotter/Navigator
#     OpenCPN supports:
#       BSB raster and S57 ENC vector charts
#       AIS Target tracking
#       NMEA GPS input
#       GPDS Daemon input
#       Autopilot output
#       Unlimited Route/Mark creation
#


TMP_DIR=/tmp/opencpn

cd "$TMP_DIR"

wget  -c --progress=dot:mega \
  "http://downloads.sourceforge.net/project/opencpn/opencpn/1.3.6/opencpn_1.3.6_i386.deb"


DEPS="libwxgtk2.8-0"
#FIXME 
# Depends: libc6 (>= 2.4), libgcc1 (>= 1:4.1.1-21), libgl1-mesa-glx | libgl1,
#  libglib2.0-0 (>= 2.12.0), libglu1-mesa | libglu1, libgtk2.0-0 (>= 2.12.0),
#  libstdc++6 (>= 4.1.1-21), libwxbase2.8-0 (>= 2.8.7.1), libwxgtk2.8-0 (>= 2.8.7.1),
#  zlib1g (>= 1:1.2.3.3.dfsg-1)
 
apt-get --assume-yes install $DEPS


dpkg -i "opencpn_1.3.6_i386.deb"

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


#### download sample data from NOAA
# RNC raster (BSB format)
# ENC vector (S-57 format)
#
# TODO


#### pre-set data paths
# TODO

#### install icon on desktop/menus
# TODO


#### install help manual
# PDF version of:
# http://opencpn.org/docwiki
#  ?
#
# TODO

