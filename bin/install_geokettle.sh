#!/bin/sh
#################################################
#
# Purpose: Installation of GeoKettle in Ubuntu
# Authors: Etienne Dube, Thierry Badard
#          <tbadard@spatialytics.com>
#          Based on uDig install script by
#          Stefan Hansen.
#
#################################################
# Copyright (c) 2009-2011 Spatialytics, (c) 2007-2009 GeoSOA Research group
#
# Licensed under the GNU LGPL.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#

# About:
# =====
# This script will install GeoKettle into Ubuntu

# Java requirements
# =================
# GeoKettle can run on either version 5 or 6 of the Sun Java JRE.
# There's no preference for Java 5 or 6 with the current version (one or the other will do fine), but future versions may rely on features only present in >= 6.

# Running:
# =======
# sudo ./install_geokettle.sh

TMP="/tmp/build_geokettle"
GEOKETTLE_BASE_URL="http://downloads.sourceforge.net/project/geokettle/geokettle-2.x/2.0"
GEOKETTLE_BASENAME="geokettle-2.0-with_plugins"
GEOKETTLE_FILENAME="$GEOKETTLE_BASENAME.zip"
INSTALL_FOLDER="/opt"
GEOKETTLE_FOLDER="$INSTALL_FOLDER/geokettle"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
#DESKTOP="Bureau"
DESKTOP="Desktop"

## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again"
   exit 1
fi
# create tmp folders
mkdir -p "$TMP/$GEOKETTLE_BASENAME"
cd "$TMP"


## Install Application ##

# get geokettle
if [ -f "$GEOKETTLE_FILENAME" ]
then
   echo "$GEOKETTLE_FILENAME has already been downloaded."
else
   wget --progress=dot:mega "$GEOKETTLE_BASE_URL/$GEOKETTLE_FILENAME" -O $GEOKETTLE_FILENAME
fi
# unpack it
unzip -q "$GEOKETTLE_FILENAME" -d "$TMP/$GEOKETTLE_BASENAME"

# move the contents to /opt/geokettle and clean the temp directory
mkdir -p "$GEOKETTLE_FOLDER"

cd "$TMP/$GEOKETTLE_BASENAME"
mv * "$GEOKETTLE_FOLDER"
cd ..
rmdir "$TMP/$GEOKETTLE_BASENAME" 

## Configure Application ##

# make shell scripts executable
chmod a+x "$GEOKETTLE_FOLDER"/*.sh

## remove unnecessary runtime libs 10Aug11
rm -rf /opt/geokettle/libext/geometry/libgdal/win32
rm -rf /opt/geokettle/libext/geometry/libgdal/win64
rm -rf /opt/geokettle/libext/geometry/libgdal/osx
rm -rf /opt/geokettle/libext/geometry/libgdal/linux/x86_64

##---------------------------------------------------------------
# Create desktop icon
cat << EOF > "$USER_HOME/$DESKTOP/geokettle.desktop"
[Desktop Entry]
Name=GeoKettle
Exec=$GEOKETTLE_FOLDER/spoon.sh
Path=$GEOKETTLE_FOLDER
Icon=$GEOKETTLE_FOLDER/ui/images/geokettle.png
Type=Application
Categories=Application;
EOF

# make the desktop icon owned by $USER_NAME and executable
chown $USER_NAME:$USER_NAME "$USER_HOME/$DESKTOP/geokettle.desktop"
chmod a+x "$USER_HOME/$DESKTOP/geokettle.desktop"

