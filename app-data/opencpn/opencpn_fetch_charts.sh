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


#### download sample data
# RNC raster (BSB format)
# ENC vector (S-57 format)


### Raster BSB charts ###
# New York Harbor:
RNC_CHARTS="
 12300
 12326
 12327
 12334
 12335
 12358
 12401
 12402
 13006"

### Vector S-57 charts ###
# New York Harbor and Long Island Sound:
CHARTS="
 US2EC03M
 US3NY01M
 US4NY13M
 US4NY1AM
 US4NY1GM
 US5CN10M
 US5CN11M
 US5CN12M
 US5NY12M
 US5NY14M
 US5NY15M
 US5NY16M
 US5NY18M
 US5NY19M
 US5NY1BM
 US5NY1CM
 US5NY1DM
 US5NY50M"



TMP_DIR=/tmp/build_opencpn

if [ -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi


# the main install script has to set the dir's group to "users" (+rw) and
#   add the user to the "users" group.
DATADIR="/usr/local/share/opencpn"





### see if user agrees to NOAA's terms
 echo "Read and accept" | \
   gxmessage -file - -buttons "I agree,I do not agree" -center
#
# echo $?
# 101  1st button 
# 102  2nd button


if [ "$ACCEPTED_TERMS" = "false" ] ; then
   exit 1
fi



### Raster BSB charts ###
cd "$TMP_DIR"

for CHART in $RNC_CHARTS ; do
  wget -c --progress=dot:mega "http://www.charts.noaa.gov/RNCs/$CHART.zip"
  wget -c -nv "http://www.charts.noaa.gov/RNCs/${CHART}_RNCProdCat.xml"
done

cd "$DATADIR/charts"

for CHART in $RNC_CHARTS ; do
   unzip "$TMP_DIR/$CHART.zip"
   cp "$TMP_DIR/${CHART}_RNCProdCat.xml" BSB_ROOT/
done


### Vector S-57 charts ###
cd "$TMP_DIR"

for CHART in $ENC_CHARTS ; do
  wget -c --progress=dot:mega "http://www.charts.noaa.gov/ENCs/$CHART.zip"
  wget -c -nv "http://www.charts.noaa.gov/ENCs/${CHART}_ENCProdCat.xml"
done

cd "$DATADIR/charts"

for CHART in $ENC_CHARTS ; do
   unzip -u -o "$TMP_DIR/$CHART.zip"
   cp "$TMP_DIR/${CHART}_ENCProdCat.xml" ENC_ROOT/
done


echo "Chart download complete."
