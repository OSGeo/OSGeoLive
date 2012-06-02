#!/bin/sh
#################################################
# 
# Purpose: Installation of GeoNetwork into Xubuntu
# Author:  Ricardo Pinho <ricardo.pinho@gisvm.com>
# Author:  Simon Pigot <simon.pigot@csiro.au>
# Small edits: Jeroen Ticheler <Jeroen.Ticheler@GeoCat.net>
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 GISVM.COM
#
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
##################################################

# About:
# =====
# This script will install geonetwork into Xubuntu
# stable version: v2.6.4 (24 May 2011) (also the manuals)
# based on Jetty + Geoserver + McKoi
# Installed at /usr/lib/geonetwork
# Port number =8880
#
# To start geonetwork
# cd /usr/lib/geonetwork/bin
# ./start-geonetwork.sh 
#
# To stop geonetwork
# cd /usr/lib/geonetwork/bin
# ./stop-geonetwork.sh
#
# To enter geonetwork, start browser with url:
# http://localhost:8880/geonetwork
#
# GeoNetwork version 2.6.4 runs with java-sun-1.5 or java-sun-1.6.
# It can be installed into servlet containers: jetty and tomcat. Jetty is   
# bundled with the installer.
#
# Running:
# =======
# sudo ./install_geonetwork.sh

TMP="/tmp/build_geonetwork"
#FIXME: please use /usr/local not /usr for things not in a .deb
INSTALL_FOLDER="/usr/lib"
GEONETWORK_FOLDER="$INSTALL_FOLDER/geonetwork"
BIN="/usr/bin"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BUILD_DIR="`pwd`"

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
if [ -f "geonetwork-install-2.6.4-0.jar" ]
then
   echo "geonetwork-install-2.6.4-0.jar has already been downloaded."
else
   wget -c --progress=dot:mega \
     "http://freefr.dl.sourceforge.net/project/geonetwork/GeoNetwork_opensource/v2.6.4/geonetwork-install-2.6.4-0.jar"
fi

# get geonetwork doco - not just yet - has to be uploaded
#if [ -f "GeoNetwork_opensource_v264_Manual.pdf" ]
#then
#   echo "GeoNetwork_opensource_v264_Manual.pdf has already been downloaded."
#else
#   wget --progress=dot:binary \
#      http://transact.dl.sourceforge.net/project/geonetwork/Documentation/v2.6.4/GeoNetwork_opensource_v264_Manual.pdf
#fi


## Get Install config files ##
# Download XML file that defines install location
# Download jetty.xml file to listen on all addresses and change Port to 8880 
#   config-gui.xml file to find default GeoServer layers Port 8880
#   start-geonetwork.sh file with mods to work from any directory
#   stop-geonetwork.sh file with mods to work from any directory
#   data-db-mckoi.sql file - changed port number 8880
#   iso-19139-basins-in-africa.mef file - changed port number 8880
#   iso-19139-physiographic.mef file - changed port number 8880

FILES="
install.xml
jetty.xml
config-gui.xml
start-geonetwork.sh
stop-geonetwork.sh
data-db-mckoi.sql
iso-19139-basins-in-africa.mef
iso-19139-physiographic.mef
"

for FILE in $FILES ; do
   cp -f -v "$BUILD_DIR/../app-conf/geonetwork/$FILE" .
done



## Install Application ##
if [ -d "$GEONETWORK_FOLDER" ]
then
	( cd "$GEONETWORK_FOLDER/bin"; ./stop-geonetwork.sh )
fi
java -jar geonetwork-install-2.6.4-0.jar install.xml


cp -f jetty.xml "$GEONETWORK_FOLDER/bin/jetty.xml"
cp -f config-gui.xml "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/config-gui.xml"
cp -f start-geonetwork.sh "$GEONETWORK_FOLDER/bin/start-geonetwork.sh"
cp -f stop-geonetwork.sh "$GEONETWORK_FOLDER/bin/stop-geonetwork.sh"
cp -f data-db-mckoi.sql \
   "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/classes/setup/sql/data/data-db-mckoi.sql"
cp -f iso-19139-basins-in-africa.mef \
   "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/classes/setup/samples/iso-19139-basins-in-africa.mef"
cp -f iso-19139-physiographic.mef \
   "$GEONETWORK_FOLDER/web/geonetwork/WEB-INF/classes/setup/samples/iso-19139-physiographic.mef"

# fix permissions on installed software
chown -R "$USER_NAME:$USER_NAME" "$GEONETWORK_FOLDER"


# create startup, shutdown, open browser and doco desktop entries
for FILE in start_geonetwork stop_geonetwork geonetwork ; do
   cp -f -v "$BUILD_DIR/../app-conf/geonetwork/$FILE.desktop" .
   cp -f "$FILE.desktop" "$USER_HOME/Desktop/$FILE.desktop"
   chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/$FILE.desktop"
done


#Manual is being put into /usr/local/share and linked to the geonetwork documentation
mkdir -p /usr/local/share/geonetwork
#cp GeoNetwork_opensource_v264_Manual.pdf /usr/local/share/geonetwork/GeoNetwork_opensource_v264_Manual.pdf
#chmod 644 /usr/local/share/geonetwork/*.pdf
#cp GeoNetwork_opensource_v264_Manual.pdf $USER_HOME/Desktop
#chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/GeoNetwork_opensource_v264_Manual.pdf


# share data with the rest of the disc
mkdir -p /usr/local/share/data/raster/
ln -s /usr/lib/geonetwork/data/geoserver_data/coverages/BlueMarble_world/bluemarble_jpeg_small.tiff \
      /usr/local/share/data/raster/BlueMarble_small.tiff

mkdir -p /usr/local/share/data/vector/
ln -s  /usr/lib/geonetwork/data/geoserver_data/data/boundaries \
      /usr/local/share/data/vector/global_boundaries

