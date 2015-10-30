#!/bin/sh
#################################################
# 
# Purpose: Installation of GeoNetwork into Xubuntu
# Author:  Ricardo Pinho <ricardo.pinho@gisvm.com>
# Author:  Simon Pigot <simon.pigot@csiro.au>
# Author:  Francois Prunayre <fx.prunayre@gmail.com>
# Small edits: Jeroen Ticheler <Jeroen.Ticheler@GeoCat.net>
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 GISVM.COM
#
# Licensed under the GNU LGPL version >= 2.1.
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
##################################################
#
# About:
# =====
# This script will install geonetwork into OSGeo live
# stable version: v3.0.1
# based on Jetty + GeoNetwork + H2
# Installed at /usr/local/lib/geonetwork
# Port number = 8880
#
# To start geonetwork
# cd /usr/local/lib/geonetwork/bin
# ./startup.sh 
#
# To stop geonetwork
# cd /usr/local/lib/geonetwork/bin
# ./shutdown.sh
#
# To enter geonetwork, start browser with url:
# http://localhost:8880/geonetwork
#
# GeoNetwork version 3.0.1 runs with java 7 or higher.
# It can be installed into servlet containers: jetty and tomcat. Jetty is   
# bundled with the installer.

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

GEONETWORK_VERSION=3.0.1-0
GEONETWORK_VERSION_FOLDER=3.0.1

TMP="/tmp/build_geonetwork"
INSTALL_FOLDER="/usr/local/lib"
GEONETWORK_FOLDER="$INSTALL_FOLDER/geonetwork"
BIN="/usr/local/bin"


## Setup things... ##
 
# check required tools are installed
# (should we also verify java???)
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
mkdir -p "$TMP"
cd "$TMP"


# get geonetwork
if [ -f "geonetwork-install-$GEONETWORK_VERSION.jar" ]
then
   echo "geonetwork-install-$GEONETWORK_VERSION.jar has already been downloaded."
else
   wget -c --progress=dot:mega \
     "http://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v$GEONETWORK_VERSION_FOLDER/geonetwork-install-$GEONETWORK_VERSION.jar/download" \
     -O geonetwork-install-$GEONETWORK_VERSION.jar
fi

## Get Install config files ##
# Those files contains information about default ports
# and need to be updated to properly setup the node on the OSGeo live machine
FILES="
install.xml
jetty.xml
startup.sh
shutdown.sh
data-db-default.sql
"

for FILE in $FILES ; do
   cp -f -v "$BUILD_DIR/../app-conf/geonetwork/$FILE" .
done



## Install Application ##
if [ -d "$GEONETWORK_FOLDER" ] ; then
   ( cd "$GEONETWORK_FOLDER/bin"; ./shutdown.sh )
fi
java -jar geonetwork-install-$GEONETWORK_VERSION.jar install.xml


cp -f jetty.xml "$GEONETWORK_FOLDER/jetty/etc/jetty.xml"
cp -f data-db-default.sql "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/classes/setup/sql/data/."
cp -f wro4j-cache.* "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/data/."
cp -f startup.sh "$GEONETWORK_FOLDER/bin/startup.sh"
cp -f shutdown.sh "$GEONETWORK_FOLDER/bin/shutdown.sh"

# fix permissions on installed software
#   what's really needed here? the logs for sure, the rest are guesses
chgrp users "$GEONETWORK_FOLDER"/jetty
chgrp users "$GEONETWORK_FOLDER"/jetty/logs -R
chgrp users "$GEONETWORK_FOLDER"/web/geonetwork/WEB-INF/ -R
chgrp users "$GEONETWORK_FOLDER"/web/geonetwork/images/logos
chmod g+w "$GEONETWORK_FOLDER"/jetty
chmod g+w "$GEONETWORK_FOLDER"/jetty/logs -R
chmod g+w "$GEONETWORK_FOLDER"/web/geonetwork/WEB-INF/ -R
chmod g+w "$GEONETWORK_FOLDER"/web/geonetwork/images/logos
adduser "$USER_NAME" users


# create startup, shutdown, open browser and doco desktop entries
for FILE in start_geonetwork stop_geonetwork geonetwork ; do
   cp -f -v "$BUILD_DIR/../app-conf/geonetwork/$FILE.desktop" .
   cp -f "$FILE.desktop" "$USER_HOME/Desktop/$FILE.desktop"
   chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/$FILE.desktop"
done

#copy project logo to use as menu icon
cd "$TMP"
wget -c --progress=dot:mega \
 "https://github.com/OSGeo/OSGeoLive-doc/raw/master/images/project_logos/logo-GeoNetwork.png" \
 -O geonetwork_icon.png
mkdir -p /usr/local/share/icons
mv geonetwork_icon.png /usr/local/share/icons/geonetwork_icon.png

# No manual/doco as these are included in the geonetwork release as html
# pages
####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
