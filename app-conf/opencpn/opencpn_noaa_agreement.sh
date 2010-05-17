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
# This script will download and install some NOAA charts for the OpenCPN
#   GPS navigation software in BSB (RNCs) and S-57 (ENCs) format.
#
#  written by H.Bowman <hamish_b  yahoo com>
#  OpenCPN homepage: http://www.opencpn.org/
#  NOAA license: redistribution allowed, but end-users have to agree to terms

# (Sorry Australians, complain to your hydrographic office that encrypting
#  safety-critical data for the purposes of "DRM" is fundamentally stupid.
#  They should rely on well-established cryptographically signed methods
#  to ensure that the data has not been corrupted or tampered with instead.
#  So we use NOAA data from the USA for our examples instead of Sydney Harbour.)

# send users to these websites as part of the min-tutorial:
#   http://www.nauticalcharts.noaa.gov/mcd/Raster/download_agreement.htm
#   http://www.nauticalcharts.noaa.gov/mcd/enc/download_agreement.htm
# find the chart numbers you want then,
#   http://www.charts.noaa.gov/RNCs/
#   http://www.charts.noaa.gov/ENCs/

## "Copying of the NOAA RNCs® to any other server or location for further
##  distribution is discouraged unless the following guidelines are followed:
##  1) this User Agreement is displayed and accepted by anyone accessing the
##  NOAA RNCs®, and 2) a reference to this Web site is included so that anyone
##  accessing the NOAA RNCs® is advised of their origin."

DATADIR="/usr/local/share/opencpn"
cd "$DATADIR"

### see if user agrees to NOAA's terms

gxmessage -file noaa_agreement.txt -center \
   -buttons "I agree,I do not agree" -default "I do not agree"

# echo $?
# 101  1st button 
# 102  2nd button

if [ $? -ne 101 ] ; then
   echo "Charts have not been activated."
   exit 1
fi

PASSWORD=user
echo "$PASSWORD" | sudo -S ln -s "$DATADIR/charts.dist" "$DATADIR/charts"

# clear the decks to force chart-list DB rebuild
for FILE in chartlist.dat navobj.xml ; do
   if [ -e ~/.opencpn/$FILE ] ; then
      \rm -f ~/.opencpn/$FILE
   fi
done

echo "Charts activated."
exit 0
