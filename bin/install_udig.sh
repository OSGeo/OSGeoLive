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
UDIG_FOLDER="$INSTALL_FOLDER/udig"
DATA_FOLDER="/usr/local/share/udig"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
 
## Setup things... ##
if [ ! -d "$DATA_FOLDER" ] ; then
   mkdir "$DATA_FOLDER"
fi
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir -p "$TMP"
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

# CASE OF A TAR.GZ
#TARBALL="udig-1.2-RC3.linux.gtk.x86.tar.gz"
#if [ -f "$TARBALL" ] ; then
#   echo "$TARBALL has already been downloaded."
#else
#   wget -c --progress=dot:mega "http://udig.refractions.net/files/downloads/$TARBALL"
#fi
# unpack it and copy it to /usr/lib
#tar -xzf "$TARBALL" -C "$INSTALL_FOLDER"
#
#if [ $? -ne 0 ] ; then
#   echo "ERROR: expanding $TARBALL"
#   exit 1
#fi
     
# CASE OF A ZIP
ZIP="udig-1.2-RC3.linux.gtk.x86.zip"
if [ -f "$ZIP" ] ; then
   echo "$ZIP has already been downloaded."
else
   wget -c --progress=dot:mega "http://udig.refractions.net/files/downloads/$ZIP"
fi
# unpack it and copy it to /usr/lib
unzip "$ZIP" -d "$INSTALL_FOLDER"

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


## Sample Data ##

# Download udig's sample data
if [ -f "data-v1_2.zip" ]
then
   echo "data-v1_2.zip has already been downloaded."
else
   wget -c --progress=dot:mega http://udig.refractions.net/docs/data-v1_2.zip # changed from 1_1 to include index
fi

#unzip the file into /usr/local/share/udig-data
mkdir "$DATA_FOLDER/udig-data"
unzip data-v1_2.zip -d "$DATA_FOLDER/udig-data"
chmod g+w "$DATA_FOLDER/udig-data"
adduser $USER_NAME users
chown root.users "$DATA_FOLDER/udig-data"


## Documentation ##

# Download udig's documentation
REL_DOC="udig-1.2-RC3.html"
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
mkdir "$DATA_FOLDER/udig-docs"
cp "$REL_DOC" "$DATA_FOLDER/udig-docs"
cp uDigWalkthrough1.pdf "$DATA_FOLDER/udig-docs"
cp uDigWalkthrough1.pdf "$DATA_FOLDER/udig-docs"

