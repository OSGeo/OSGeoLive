#!/bin/sh
# Copyright (c) 2011 The Open Source Geospatial Foundation.
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
# This script will ask the user about the NOAA agreement if the user hasn't
#   answered it yet, then launch OpenCPN
#  see opencpn_noaa_agreement.sh
#
#  written by H.Bowman <hamish_b  yahoo com>
#  OpenCPN homepage: http://www.opencpn.org/
#  NOAA license: redistribution allowed, but end-users have to agree to terms
#

DATADIR="/usr/local/share/opencpn"

if [ ! -e "$DATADIR/charts" ] ; then
   opencpn_noaa_agreement.sh
fi

exec opencpn
