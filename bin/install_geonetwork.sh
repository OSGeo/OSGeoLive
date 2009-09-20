#!/bin/sh
#################################################
# 
# Purpose: Installation of GeoNetwork into Xubuntu
# Author:  Ricardo Pinho <ricardo.pinho@gisvm.com>
# Author:  Simon Pigot <simon.pigot@csiro.au>
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
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
# stable version: v2.4.1 (20 August 2009) (also the manuals)
# based on Jetty + Geoserver + McKoi
# Installed at /usr/lib/geonetwork
# Port number =8880
#
# To start geonetwork
# cd /usr/lib/geonetwork
# sudo ./start-geonetwork.sh 
#
# To stop geoserver
# sudo ./stop-geonetwork.sh
#
# To enter geoserver
# http://localhost:8880/geonetwork

# Running:
# =======
# sudo ./install_geonetwork.sh

TMP="/tmp/geonetwork_downloads"
INSTALL_FOLDER="/usr/lib"
#DATA_FOLDER="/usr/local/share"
GEONETWORK_FOLDER="$INSTALL_FOLDER/geonetwork"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
 
## Setup things... ##
 
# check required tools are installed
# (should we also verify java???)
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir $TMP
cd $TMP


# get geonetwork
if [ -f "geonetwork-install-2.4.1-0.jar" ]
then
   echo "geonetwork-install-2.4.1-0.jar has already been downloaded."
else
   wget -c --progress=dot:mega http://freefr.dl.sourceforge.net/project/geonetwork/GeoNetwork_opensource/v2.4.1/geonetwork-install-2.4.1-0.jar
fi

# get geonetwork doco
if [ -f "GeoNetwork_opensource_v240_Manual.pdf" ]
then
   echo "GeoNetwork_opensource_v240_Manual.pdf has already been downloaded."
else
   wget --progress=dot:binary http://transact.dl.sourceforge.net/project/geonetwork/Documentation/v2.4.0/GeoNetwork_opensource_v240_Manual.pdf
fi


## Get Install config files ##

# Download XML file that defines install location = 
if [ -f "install.xml" ]
then
   echo "install.xml has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/install.xml
fi

# Download jetty.xml file to listen on all addresses and change Port to 8880 
if [ -f "jetty.xml" ]
then
   echo "jetty.xml has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/jetty.xml
fi

# Download mapServers.xml file to find default GeoServer layers Port 8880
if [ -f "mapServers.xml" ]
then
   echo "mapServers.xml has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/mapServers.xml
fi


## Install Application ##
if [ -d "$GEONETWORK_FOLDER" ]
then
	( cd $GEONETWORK_FOLDER/bin; ./stop-geonetwork.sh )
fi
sudo java -jar geonetwork-install-2.4.1-0.jar install.xml


# copy jetty.xml to $GEONETWORK_FOLDER/bin
sudo cp jetty.xml $GEONETWORK_FOLDER/bin/jetty.xml

# copy mapServers.xml to $GEONETWORK_FOLDER/web/intermap/WEB-INF
sudo cp mapServers.xml $GEONETWORK_FOLDER/web/intermap/WEB-INF/mapServers.xml

# fix permissions on installed software
sudo chown -R $USER_NAME:$USER_NAME $GEONETWORK_FOLDER


# create startup, shutdown, open browser and doco desktop entries
if [ -f "start_geonetwork.desktop" ]
then
	echo "start_geonetwork.desktop has already been downloaded"
else
	wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/start_geonetwork.desktop
fi
cp start_geonetwork.desktop $USER_HOME/Desktop/start_geonetwork.desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/start_geonetwork.desktop


if [ -f "stop_geonetwork.desktop" ]
then
	echo "stop_geonetwork.desktop has already been downloaded"
else
	wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/stop_geonetwork.desktop
fi
cp stop_geonetwork.desktop $USER_HOME/Desktop/stop_geonetwork.desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/stop_geonetwork.desktop

if [ -f "geonetwork.desktop" ]
then
	echo "geonetwork.desktop has already been downloaded"
else
	wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/geonetwork-conf/geonetwork.desktop
fi
cp geonetwork.desktop $USER_HOME/Desktop/geonetwork.desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/geonetwork.desktop

cp GeoNetwork_opensource_v240_Manual.pdf $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/GeoNetwork_opensource_v240_Manual.pdf

exit 0
