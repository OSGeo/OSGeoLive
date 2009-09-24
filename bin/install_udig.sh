#!/bin/sh
#################################################
# 
# Purpose: Installation of udig into Xubuntu
# Author:  Stefan Hansen <shansen@lisasoft.com>
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2009 LISAsoft
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
# This script will install udig into Xubuntu

# Running:
# =======
# sudo ./install_udig.sh

TMP="/tmp/udig_downloads"
INSTALL_FOLDER="/usr/lib"
DATA_FOLDER="/usr/local/share"
UDIG_FOLDER="$INSTALL_FOLDER/udig"
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
mkdir "$TMP"
cd "$TMP"


## Install Application ##

# get udig
# 
# This download incudes a "jre" folder containing a customized Java Runtime
# Environment that has been extended with
# - Java Advanced Imaging
# - Java ImageIO
# - Java ImageIO-Ext
# - GDAL
# 
# Notes for future maintainers:
# - This jre could be removed in the future providing the system JRE was set
#   up in a similar manner (http://udig.refractions.net/confluence/display/ADMIN/JRE+for+Linux)
# - GDAL could also be removed if GDAL_DATA environment variable is defined etc..
#   For specific env requirements please review udig.sh script

if [ -f "udig-1.2-M6.linux.gtk.x86.tar.gz" ]
then
   echo "udig-1.2-M6.linux.gtk.x86.tar.gz has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/files/downloads/branches/udig-1.2-M6.linux.gtk.x86.tar.gz
fi
# unpack it and copy it to /usr/lib
tar -xzf udig-1.2-M6.linux.gtk.x86.tar.gz -C $INSTALL_FOLDER


## Configure Application ##

# Download modified startup script for udig
if [ -f "udig.sh" ]
then
   echo "udig.sh has already been downloaded."
else
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/udig-conf/udig.sh
fi
# copy it into the udig folder
cp udig.sh $UDIG_FOLDER

# create link to startup script
ln -s $UDIG_FOLDER/udig.sh $BIN/udig

# Download desktop icon
if [ -f "uDig.desktop" ]
then
   echo "uDig.desktop has already been downloaded."
else
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/udig-conf/uDig.desktop
fi
# copy it into the udig folder
cp uDig.desktop $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/uDig.desktop


## Sample Data ##

# Download udig's sample data
if [ -f "data-v1_2.zip" ]
then
   echo "data-v1_2.zip has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/docs/data-v1_2.zip # changed from 1_1 to include index
fi

#unzip the file into /usr/local/share/udig-data
mkdir $DATA_FOLDER/udig-data
unzip data-v1_2.zip -d $DATA_FOLDER/udig-data
chmod a+w $DATA_FOLDER/udig-data

## Documentation ##

# Download udig's documentation
if [ -f "udig-1.2-M5.html" ]
then
   echo "udig-1.2-M5.html has already been downloaded."
else
   wget -nv http://udig.refractions.net/files/downloads/branches/udig-1.2-M5.html
fi

if [ -f "uDigWalkthrough1.pdf" ]
then
   echo "uDigWalkthrough1.pdf has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/docs/uDigWalkthrough1.pdf
fi

if [ -f "uDigWalkthrough2.pdf" ]
then
   echo "uDigWalkthrough2.pdf has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/docs/uDigWalkthrough2.pdf
fi

#copy into /usr/local/share/udig-docs
mkdir $DATA_FOLDER/udig-docs
cp udig-1.2-M5.html $DATA_FOLDER/udig-docs
cp uDigWalkthrough1.pdf $DATA_FOLDER/udig-docs
cp uDigWalkthrough1.pdf $DATA_FOLDER/udig-docs
