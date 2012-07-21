#!/bin/sh
# Copyright (c) 2009-2010 The Open Source Geospatial Foundation.
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
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


TMP_DIR=/tmp/build_opencpn
WD=`pwd`

if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

URL="http://download.osgeo.org/livedvd/data/opencpn/precise/i386"
PKGS="
opencpn-data_2.5.0+dfsg-0_all.deb
opencpn-doc_2.5.0+dfsg-0_all.deb
opencpn_2.5.0+dfsg-0_i386.deb
opencpn-plugins_2.5.0+dfsg-0_i386.deb
"
for PKG in $PKGS ; do
   wget -c --progress=dot:mega "$URL/$PKG"
done


# recommended:
apt-get --assume-yes install gpsd gpsd-clients python-gps

# dpkg -I <packagename.deb>
# Depends: libatk1.0-0 (>= 1.29.3), libbz2-1.0, libc6 (>= 2.7), libcairo2 (>= 1.2.4),
#  libgcc1 (>= 1:4.1.1), libgl1-mesa-glx | libgl1, libglib2.0-0 (>= 2.12.0),
#  libglu1-mesa | libglu1, libgtk2.0-0 (>= 2.8.0), libice6 (>= 1:1.0.0),
#  libpango1.0-0 (>= 1.14.0), libsm6, libstdc++6 (>= 4.1.1), libtinyxml2.6.2 (>= 2.5.3-3),
#  libwxbase2.8-0 (>= 2.8.10.1), libwxgtk2.8-0 (>= 2.8.10.1), libx11-6, libxext6,
#  zlib1g (>= 1:1.1.4), libgps19

DEPS="libgl1-mesa-glx libglu1-mesa \
      libglib2.0-0 libgtk2.0-0 libstdc++6 \
      libwxbase2.8-0 libwxgtk2.8-0 zlib1g \
      libtinyxml2.6.2"

apt-get --assume-yes install $DEPS

for PKG in $PKGS ; do
   gdebi --non-interactive --quiet "$PKG"

   if [ $? -ne 0 ] ; then
      echo 'ERROR: Package install failed! Aborting.'
      exit 1
   fi
done

wget -nv -O tips.html \
  "http://opencpn.cvs.sourceforge.net/viewvc/*checkout*/opencpn/opencpn/data/doc/tips.html"
cp tips.html /usr/local/share/opencpn/doc/


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

## "Copying of the NOAA RNCs® to any other server or location for further
##  distribution is discouraged unless the following guidelines are followed:
##  1) this User Agreement is displayed and accepted by anyone accessing the
##  NOAA RNCs®, and 2) a reference to this Web site is included so that anyone
##  accessing the NOAA RNCs® is advised of their origin."


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
cd "$WD"
cp ../app-conf/opencpn/noaa_agreement.txt "$DATADIR/"
cp ../app-conf/opencpn/opencpn_noaa_agreement.sh /usr/local/bin/
cp ../app-conf/opencpn/launch_opencpn.sh /usr/local/bin/
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
VPLatLon="   40.39,  -73.27"
VPScale=0.0048
OwnShipLatLon="   40.337,   -73.272"
nBoundaryStyle=79
EOF

chown -R $USER_NAME.$USER_NAME "$USER_HOME/.opencpn/"


#### install icon on desktop/menus
cd "$TMP_DIR"
wget -nv "http://opencpn.cvs.sourceforge.net/viewvc/*checkout*/opencpn/opencpn/data/opencpn.png" \
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

