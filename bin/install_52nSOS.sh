#!/bin/sh
#############################################################################
#
# Purpose: This script will install 52nSOS with docker
# Author: e.h.juerrens@52north.org, c.hollmann@52north.org
# Version 2026-01-06
#
#############################################################################
# Copyright (c) 2011-2026 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#############################################################################

START=$(date +%M:%S)
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_52nSOS"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

docker pull 52north/sos:5.5
docker run --name sos -d -p 8089:8080 52north/sos:5.5
docker stop sos

mkdir -p -v "$USER_HOME/Desktop"

cp -f -v "$BUILD_DIR/../app-conf/52n/52n.png" /usr/local/share/icons/52n.png
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/52nSOS-start.desktop ] ; then
    cat << EOF > /usr/local/share/applications/52nSOS-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthSOS
Comment=52North SOS
Categories=Geospatial;Servers;
Exec=docker start sos && firefox http://localhost:8089/ http://localhost/osgeolive/en/overview/52nSOS_overview.html
Icon=/usr/local/share/icons/52n.png
Terminal=false
EOF
fi

cp -v /usr/local/share/applications/52nSOS-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-start.desktop"

if [ ! -e /usr/local/share/applications/52nSOS-stop.desktop ] ; then
    cat << EOF > /usr/local/share/applications/52nSOS-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop 52NorthSOS
Comment=52North SOS
Categories=Geospatial;Servers;
Exec=docker stop sos
Icon=/usr/local/share/icons/52n.png
Terminal=false
EOF
fi

cp -v /usr/local/share/applications/52nSOS-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-stop.desktop"

"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
echo -e "Timing:\nStart: $START\nEnd  : $(date +%M:%S)"
