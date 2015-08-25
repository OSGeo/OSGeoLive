#!/bin/sh
#################################################
# 
# Purpose: Installation of Kosmo into Lubuntu
# Author:  Sergio Banos Calvo <sbc@saig.es> - SAIG <info@saig.es>
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2010 SAIG
#
# Licensed under the GNU GPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, either
# in the "LICENSE.GPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/gpl.html".
##################################################

# About:
# =====
# This script will install Kosmo 3.1 into OSGeo LiveDVD

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_kosmo.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_kosmo.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ "$ARCH" = "amd64" ] ; then
    "$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
    exit 1
fi

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
TMP="/tmp/build_kosmo"
INSTALL_FOLDER="/usr/lib"
KOSMO_FOLDER="$INSTALL_FOLDER/Kosmo-3.1"
BIN="/usr/bin"
USER_HOME="/home/$USER_NAME"

## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir -p "$TMP"
cd "$TMP"

## Install Application ##

# get kosmo
wget -c --progress=dot:mega \
   "http://www.kosmoland.es/public/kosmo/v_3.1/livedvd/kd_3.1_lin32_jre_20140707-1257.tar.gz"

# unpack it and copy it to /usr/lib
tar xzf kd_3.1_lin32_jre_20140707-1257.tar.gz \
   -C "$INSTALL_FOLDER" --no-same-owner

if [ $? -ne 0 ] ; then
   echo "ERROR: Kosmo download failed."
   exit 1
fi

adduser "$USER_NAME" users
chgrp -R users "$KOSMO_FOLDER"
chmod -R g+w "$KOSMO_FOLDER"

## execute the links.sh script
cd "$KOSMO_FOLDER"/native
cp -f "$BUILD_DIR"/../app-conf/kosmo/links.sh .
chmod a+x "$KOSMO_FOLDER"/native/links.sh
./links.sh
cd "$TMP"

# get correct kosmo.sh
rm "$KOSMO_FOLDER"/bin/Kosmo.sh
cp "$BUILD_DIR"/../app-conf/kosmo/Kosmo.sh "$KOSMO_FOLDER"/bin/
chmod a+x "$KOSMO_FOLDER"/bin/Kosmo.sh

# create link to startup script
ln -s "$KOSMO_FOLDER"/bin/Kosmo.sh /usr/bin/kosmo_3.1

# Create desktop link
cat << EOF > ./Kosmo_3.1.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=Kosmo Desktop
Type=Application
Comment=
Categories=Application;
Exec=kosmo_3.1
Path=/usr/lib/Kosmo-3.1/bin/
Icon=/usr/lib/Kosmo-3.1/app-icon.ico
Terminal=false
StartupNotify=false
GenericName=
GenericName[es_ES]=
Name[es_ES]=Kosmo Desktop
EOF

# copy it into the Kosmo_3.1 folder
cp Kosmo_3.1.desktop "$USER_HOME"/Desktop
chown "$USER_NAME:$USER_NAME" "$USER_HOME"/Desktop/Kosmo_3.1.desktop
chmod a+r "$USER_HOME"/Desktop/Kosmo_3.1.desktop


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
