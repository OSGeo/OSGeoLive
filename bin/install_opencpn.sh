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
# This script will install the OpenCPN GPS navigation software
#    written by H.Bowman <hamish_b  yahoo com>
#    OpenCPN homepage: http://www.opencpn.org/
#    OpenCPN license: GPLv2
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

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


TMP_DIR=/tmp/opencpn

if [ -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

wget -c --progress=dot:mega \
  "http://downloads.sourceforge.net/project/opencpn/opencpn/1.3.6/opencpn_1.3.6_i386.deb"


# dpkg -I <packagename.deb>
# Depends: libc6 (>= 2.4), libgcc1 (>= 1:4.1.1-21), libgl1-mesa-glx | libgl1,
#  libglib2.0-0 (>= 2.12.0), libglu1-mesa | libglu1, libgtk2.0-0 (>= 2.12.0),
#  libstdc++6 (>= 4.1.1-21), libwxbase2.8-0 (>= 2.8.7.1), libwxgtk2.8-0 (>= 2.8.7.1),
#  zlib1g (>= 1:1.2.3.3.dfsg-1)

DEPS="libgl1-mesa-glx libglu1-mesa \
      libglib2.0-0 libgtk2.0-0 libstdc++6 \
      libwxbase2.8-0 libwxgtk2.8-0 zlib1g"

apt-get --assume-yes install $DEPS

dpkg -i "opencpn_1.3.6_i386.deb"

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


#### download sample data
# RNC raster (BSB format)
# ENC vector (S-57 format)
#
# (Sorry Australians, complain to your hydrographic office that encrypting
#  safety-critical data for the purposes of "DRM" is fundamentally stupid.
#  They should rely on well-established cryptographically signed methods
#  to ensure that the data has not been corrupted or tampered with instead.
#  So we use NOAA data from the USA for our examples instead of Sydney Harbour.)

# send users to these websites as part of the min-tutorial:
# http://www.nauticalcharts.noaa.gov/mcd/Raster/download_agreement.htm
# http://www.nauticalcharts.noaa.gov/mcd/enc/download_agreement.htm
# find the chart numbers you want then,
#   http://www.charts.noaa.gov/RNCs/

DATADIR="/usr/local/share/opencpn"
mkdir -p "$DATADIR/charts/BSB_ROOT"
mkdir -p "$DATADIR/charts/ENC_ROOT"

adduser "$USER_NAME" users
chown -R root.users "$DATADIR"
chmod -R g+rw "$DATADIR"


## "Copying of the NOAA RNCs® to any other server or location for further
##  distribution is discouraged unless the following guidelines are followed:
##  1) this User Agreement is displayed and accepted by anyone accessing the
##  NOAA RNCs®, and 2) a reference to this Web site is included so that anyone
##  accessing the NOAA RNCs® is advised of their origin."

###  data install moved to user-init'd run-time script "opencpn_fetch_charts.sh"

# for data install license agreement question in the user-run data fetch script:
apt-get --assume-yes install gxmessage


#### pre-set config file with data paths and initial position
# GPX tracks, etc:
mkdir "$DATADIR/gpx"
# GRIB weather data downloads:
mkdir "$DATADIR/grib"
# seed config file:
mkdir "$USER_HOME/.opencpn"

cat << EOF > "$USER_HOME/.opencpn/opencpn.conf"
[Directories]
InitChartDir=$DATADIR/charts
GPXIODir=$DATADIR/gpx
GRIBDirectory=$DATADIR/grib
[ChartDirectories]
ChartDir1=$DATADIR/charts/BSB_ROOT
ChartDir2=$DATADIR/charts/ENC_ROOT
[Settings/GlobalState]
VPLatLon="   40.58,  -71.02"
VPScale=0.00135726
OwnShipLatLon="   40.58,   -71.02"
nBoundaryStyle=79
EOF
#S57DataLocation=/usr/src/cvs/opencpn/data/s57data


#### install icon on desktop/menus
wget -nv -c "http://opencpn.cvs.sourceforge.net/viewvc/*checkout*/opencpn/opencpn/data/opencpn.png"
cp opencpn.png /usr/share/icons/

cat << EOF > /usr/share/applications/opencpn.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenCPN
Comment=GPS Navigation. You need to setup Gpsd manually
Categories=Application;Education;Geography;
Exec=/usr/local/bin/opencpn
Icon=exec
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

