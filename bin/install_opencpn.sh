#!/bin/sh
#############################################################################
#
# Purpose: This script will install the OpenCPN GPS navigation software
# Author: by H.Bowman <hamish_b  yahoo com>
# OpenCPN homepage: http://www.opencpn.org/
# OpenCPN license: GPLv2
#
#############################################################################
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation and others.
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
#############################################################################

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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

apt-get --assume-yes install gpsd gpsd-clients python-gps opencpn opencpn-doc

TMP_DIR=/tmp/build_opencpn

if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

#
# wget -nv -O tips.html \
#   "http://opencpn.cvs.sourceforge.net/viewvc/*checkout*/opencpn/opencpn/data/doc/tips.html"
# mkdir -p /usr/share/doc/opencpn-doc/doc/
# cp tips.html /usr/share/doc/opencpn-doc/doc/
#

#### download sample data
# RNC raster (BSB format)
# ENC vector (S-57 format)
#
# (Sorry Australians, complain to your hydrographic office that encrypting
#  safety-critical data for the purposes of "DRM" is fundamentally stupid.
#  They should rely on well-established cryptographically signed methods
#  to ensure that the data has not been corrupted or tampered with instead.
#  So we use NOAA data from the USA for our examples instead of Sydney Harbour.)

DATADIR="/usr/local/share/opencpn"
mkdir -p "$DATADIR/c.dist/BSB_ROOT"
mkdir -p "$DATADIR/c.dist/ENC_ROOT"

mkdir "$DATADIR/gpx"   # GPX tracks, etc
mkdir "$DATADIR/grib"  # GRIB weather data downloads:

adduser "$USER_NAME" users
chown -R root.users "$DATADIR"
chmod -R g+rw "$DATADIR"

# send users to these websites as part of the min-tutorial:
# http://www.nauticalcharts.noaa.gov/mcd/Raster/download_agreement.htm
# http://www.nauticalcharts.noaa.gov/mcd/enc/download_agreement.htm
# find the chart numbers you want then,
#   http://www.charts.noaa.gov/RNCs/

## "Copying of the NOAA RNCs� to any other server or location for further
##  distribution is discouraged unless the following guidelines are followed:
##  1) this User Agreement is displayed and accepted by anyone accessing the
##  NOAA RNCs�, and 2) a reference to this Web site is included so that anyone
##  accessing the NOAA RNCs� is advised of their origin."


### Raster BSB charts ###
# New York Harbor:
#RNC_CHARTS="
# 12300
# 12326
# 12327
# 12334
# 12335
# 12358
# 12401
# 12402
# 13006"
# save space; fewer:
RNC_CHARTS="
 12300
 12326
 12327
 12402
 13006"


### Raster BSB charts ###
cd "$TMP_DIR"

for CHART in $RNC_CHARTS ; do
  wget -N --progress=dot:mega "http://www.charts.noaa.gov/RNCs/$CHART.zip"
  if [ $? -ne 0 ] ; then
     # try try again
     wget -N --progress=dot:mega "http://www.charts.noaa.gov/RNCs/$CHART.zip"
  fi
  wget -N -nv "http://www.charts.noaa.gov/RNCs/${CHART}_RNCProdCat.xml"
done

cd "$DATADIR/c.dist"

for CHART in $RNC_CHARTS ; do
   unzip -u -o "$TMP_DIR/$CHART.zip"
   cp "$TMP_DIR/${CHART}_RNCProdCat.xml" BSB_ROOT/
done


### Vector S-57 charts ###
# New York Harbor and Long Island Sound:
#ENC_CHARTS="
# US2EC03M
# US3NY01M
# US4NY13M
# US4NY1AM
# US4NY1GM
# US5CN10M
# US5CN11M
# US5CN12M
# US5NY12M
# US5NY14M
# US5NY15M
# US5NY16M
# US5NY18M
# US5NY19M
# US5NY1BM
# US5NY1CM
# US5NY1DM
# US5NY50M"
# save space; fewer:
ENC_CHARTS="
 US2EC03M
 US3NY01M
 US4NY1AM
 US5NY19M
 US5NY1CM"


cd "$TMP_DIR"

for CHART in $ENC_CHARTS ; do
  wget -N --progress=dot:mega "http://www.charts.noaa.gov/ENCs/$CHART.zip"
  if [ $? -ne 0 ] ; then
     # try try again
    wget -N --progress=dot:mega "http://www.charts.noaa.gov/ENCs/$CHART.zip"
  fi
  wget -N -nv "http://www.charts.noaa.gov/ENCs/${CHART}_ENCProdCat.xml"
done

cd "$DATADIR/c.dist"

for CHART in $ENC_CHARTS ; do
   unzip -u -o "$TMP_DIR/$CHART.zip"
   cp "$TMP_DIR/${CHART}_ENCProdCat.xml" ENC_ROOT/
done


echo "Chart download complete."


###  data acceptance in user-init'd run-time script "opencpn_noaa_agreement.sh"
# for data install license agreement question in the user-run data fetch script:
cd "$BUILD_DIR"
cp ../app-conf/opencpn/noaa_agreement.txt "$DATADIR/"
cp ../app-conf/opencpn/opencpn_noaa_agreement.sh /usr/local/bin/
cp ../app-conf/opencpn/launch_opencpn.sh /usr/local/bin/
apt-get --assume-yes install gxmessage


#### pre-set config file with data paths and initial position

mkdir /etc/skel/.opencpn

cat << EOF > "/etc/skel/.opencpn/opencpn.conf"
[Directories]
InitChartDir=$DATADIR/charts
GPXIODir=$DATADIR/gpx
GRIBDirectory=$DATADIR/grib
[ChartDirectories]
ChartDir1=$DATADIR/charts/BSB_ROOT
ChartDir2=$DATADIR/charts/ENC_ROOT
[Settings/GlobalState]
VPLatLon="   40.39,  -73.47"
VPScale=0.0048
OwnShipLatLon="   40.337,   -73.472"
nBoundaryStyle=79
FrameWinX=800
[Settings/NMEADataSource]
DataConnections=1;2;localhost;2947;0;;4800;1;0;0;;0;;0;0;0;0;1
EOF

mkdir "$USER_HOME/.opencpn"
cp "/etc/skel/.opencpn/opencpn.conf" "$USER_HOME/.opencpn/"
chown -R "$USER_NAME.$USER_NAME" "$USER_HOME/.opencpn/"

#### install icon on desktop/menus
cd "$TMP_DIR"
wget -nv "https://github.com/OpenCPN/OpenCPN/raw/master/data/opencpn.png" \
  -O opencpn.png
cp opencpn.png /usr/share/icons/

cat << EOF > /usr/share/applications/opencpn.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenCPN
Comment=GPS Navigation. You need to setup Gpsd manually
Categories=Application;Education;Geography;
Exec=/usr/local/bin/launch_opencpn.sh
Icon=/usr/share/icons/opencpn.png
Terminal=false
EOF

cp /usr/share/applications/opencpn.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/opencpn.desktop"

# add menu item
if [ ! -e /usr/share/menu/opencpn ] ; then
   cat << EOF > /usr/share/menu/opencpn
?package(opencpn):needs="x11"\
  section="Applications/Science/Geoscience"\
  longtitle="OpenCPN Ocean Navigator"\
  title="OpenCPN" command="opencpn"\
  icon="/usr/share/icons/opencpn.png"
EOF

   update-menus
fi


#### install help manual
# PDF version of:
# http://opencpn.org/docwiki
#  ?
# just point to /usr/local/share/opencpn/doc/help.html


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
