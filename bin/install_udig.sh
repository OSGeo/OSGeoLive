#!/bin/sh
#################################################
# 
# Purpose: Installation of udig into Xubuntu
# Author:  Stefan Hansen <shansen@lisasoft.com>
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
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


TMP="/tmp/build_udig"
INSTALL_FOLDER="/usr/lib"
UDIG_VERSION="1.2.2"
UDIG_FOLDER="$INSTALL_FOLDER/udig"
DOCS_FOLDER="/usr/local/share/udig"
DATA_GLOBAL="/usr/local/share/data"

JAVA_INSTALL_FOLDER=/usr/lib/jvm/java-7-openjdk-i386/jre

BIN="/usr/bin"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
 
## Setup things... ##
if [ ! -d "$DOCS_FOLDER" ] ; then
   mkdir -p "$DOCS_FOLDER"
fi
if [ ! -d "$DATA_GLOBAL" ] ; then
   mkdir -p "$DATA_GLOBAL"
fi

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

#Dependency for Udig to load web views correctly
cp ../sources.list.d/geopublishing.list /etc/apt/sources.list.d/
# Get and import the key that the .deb packages are signed with
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD
apt-get -q update
apt-get --assume-yes install xulrunner-1.9.2


## Install Application ##

# create tmp folders
mkdir -p "$TMP"
cd "$TMP"

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

# CASE OF A ZIP
ZIP="udig-$UDIG_VERSION.linux.gtk.x86.zip"
if [ -f "$ZIP" ] ; then
   echo "$ZIP has already been downloaded."
else
   wget -c --progress=dot:mega "http://udig.refractions.net/files/downloads/$ZIP"
fi
# unpack it and copy it to /usr/lib
unzip -q "$ZIP" -d "$INSTALL_FOLDER"

if [ $? -ne 0 ] ; then
   echo "ERROR: expanding $ZIP"
   exit 1
fi




## Configure Application ##

# Download modified startup script for udig
if [ -f "udig.sh" ]
then
   echo "udig.sh has already been downloaded."
else
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/udig/udig.sh
fi
# copy it into the udig folder
cp udig.sh "$UDIG_FOLDER"

# create link to startup script
ln -s "$UDIG_FOLDER/udig.sh" "$BIN/udig"

# Download desktop icon
if [ -f "uDig.desktop" ]
then
   echo "uDig.desktop has already been downloaded."
else
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/udig/uDig.desktop
fi
# copy it into the udig folder
cp uDig.desktop "$USER_HOME/Desktop"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/uDig.desktop"


# clean up bundled jre and add jai libs to  openJDK 7 
# see ticket http://trac.osgeo.org/osgeo/ticket/922
# copy jai libs into openjdk lib/ext folder
cp $UDIG_FOLDER/jre/lib/ext/jai_*.jar $JAVA_INSTALL_FOLDER/lib/ext/

#delete jre folder from udig install folder
rm -rf $UDIG_FOLDER/jre

## Documentation ##

# Download udig's documentation
REL_DOC="udig-$UDIG_VERSION.html"
if [ -f "$REL_DOC" ] ; then
   echo "$REL_DOC has already been downloaded."
else
   wget -nv "http://udig.refractions.net/files/downloads/$REL_DOC"
fi

if [ -f "uDigWalkthrough1.pdf" ]
then
   echo "uDigWalkthrough1.pdf has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/files/tutorials/uDigWalkthrough1.pdf
fi

if [ -f "uDigWalkthrough2.pdf" ]
then
   echo "uDigWalkthrough2.pdf has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/files/tutorials/uDigWalkthrough2.pdf
fi

#copy into /usr/local/share/udig/udig-docs
mkdir -p "$DOCS_FOLDER/udig-docs"
cp "$REL_DOC" "$DOCS_FOLDER/udig-docs"
cp uDigWalkthrough1.pdf "$DOCS_FOLDER/udig-docs"
cp uDigWalkthrough1.pdf "$DOCS_FOLDER/udig-docs"

