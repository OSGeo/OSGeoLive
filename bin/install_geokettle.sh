#!/bin/sh
#################################################
#
# Purpose: Installation of GeoKettle in Ubuntu
# Author:  Etienne Dube <etdube (at) gmail.com>
#          Based on uDig install script by
#          Stefan Hansen.
#
#################################################
# Copyright (c) 2009 GeoSOA research group, Laval University
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
# A >=1.5.0 Java runtime (i.e. Sun JRE) is required for GeoKettle

# Running:
# =======
# sudo ./install_geokettle.sh

TMP="/tmp/geokettle_downloads"
INSTALL_FOLDER="/opt"
GEOKETTLE_FOLDER="$INSTALL_FOLDER/geokettle"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again"
   exit 1
fi
# create tmp folders
mkdir $TMP
cd $TMP


## Install Application ##

# get udig
if [ -f "geokettle-3.2.0-20090609-bin.zip" ]
then
   echo "geokettle-3.2.0-20090609-bin.zip has already been downloaded."
else
   wget "http://downloads.sourceforge.net/project/geokettle/geokettle/3.2.0-20090609/geokettle-3.2.0-20090609-bin.zip" -O geokettle-3.2.0-20090609-bin.zip
fi
# unpack it
unzip geokettle-3.2.0-20090609-bin.zip -d $TMP
# move the contents to /opt/geokettle
mv $TMP/geokettle-3.2.0-20090609-bin $GEOKETTLE_FOLDER

## Configure Application ##

# make shell scripts executable
chmod a+x $GEOKETTLE_FOLDER/*.sh

# Create desktop icon
# copy it into the udig folder
# FIXME: Desktop folder may be named differently in localized setups (if the language is not English)
echo "#!/usr/bin/env xdg-open" > $USER_HOME/Desktop/geokettle.desktop
echo "[Desktop Entry]" >> $USER_HOME/Desktop/geokettle.desktop
echo "Name=GeoKettle" >> $USER_HOME/Desktop/geokettle.desktop
echo "Exec=$GEOKETTLE_FOLDER/spoon.sh" >> $USER_HOME/Desktop/geokettle.desktop
echo "Path=$GEOKETTLE_FOLDER" >> $USER_HOME/Desktop/geokettle.desktop
echo "Icon=$GEOKETTLE_FOLDER/spoon.png" >> $USER_HOME/Desktop/geokettle.desktop
echo "Type=Application" >> $USER_HOME/Desktop/geokettle.desktop
echo "Categories=Application;" >> $USER_HOME/Desktop/geokettle.desktop

# make the desktop icon owned by $USER_NAME and executable
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/geokettle.desktop
chmod a+x $USER_HOME/Desktop/geokettle.desktop

