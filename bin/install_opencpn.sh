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


TMP_DIR=/tmp/build_opencpn

if [ ! -d "$TMP_DIR" ] ; then
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

DATADIR="/usr/local/share/opencpn"
mkdir -p "$DATADIR/charts/BSB_ROOT"
mkdir -p "$DATADIR/charts/ENC_ROOT"

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

## "Copying of the NOAA RNCs® to any other server or location for further
##  distribution is discouraged unless the following guidelines are followed:
##  1) this User Agreement is displayed and accepted by anyone accessing the
##  NOAA RNCs®, and 2) a reference to this Web site is included so that anyone
##  accessing the NOAA RNCs® is advised of their origin."


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
# New York Harbor and Long Island Sound:
ENC_CHARTS="
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


###  data acceptance in user-init'd run-time script "opencpn_noaa_agreement.sh"
# for data install license agreement question in the user-run data fetch script:
chmod a-r "$DATADIR/charts"
cp ../app-data/opencpn/noaa_agreement.txt "$DATADIR/"
cp ../app-data/opencpn/opencpn_noaa_agreement.sh /usr/local/bin/
apt-get --assume-yes install gxmessage



#### pre-set config file with data paths and initial position
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

