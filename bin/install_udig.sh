#!/bin/sh
#############################################################################
#
# Purpose: Installation of udig into Xubuntu
# Author:  Stefan Hansen <shansen@lisasoft.com>
#
#############################################################################
# Copyright (c) 2010-2020 Open Source Geospatial Foundation (OSGeo) and others.
# Copyright (c) 2009 LISAsoft
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
#############################################################################

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_udig.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_udig.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_udig"
INSTALL_FOLDER="/usr/lib"
UDIG_VERSION="2.2.0.RC1"
UDIG_FOLDER="$INSTALL_FOLDER/udig"
DOCS_FOLDER="/usr/local/share/udig"
DATA_GLOBAL="/usr/local/share/data"

#JAVA_INSTALL_FOLDER=/usr/lib/jvm/java-7-openjdk-i386/jre
JAVA_INSTALL_FOLDER=/usr/lib/jvm/default-java/jre

BIN="/usr/bin"

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

# #Dependency for Udig to load web views correctly
# cp ../sources.list.d/geopublishing.list /etc/apt/sources.list.d/
# # Get and import the key that the .deb packages are signed with
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD
# apt-get -q update
# # apt-get --assume-yes install xulrunner-1.9.2


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
if [ "$ARCH" = "i386" ] ; then
    ZIP="udig-$UDIG_VERSION.linux.gtk.x86.zip"
fi

if [ "$ARCH" = "amd64" ] ; then
    ZIP="udig-$UDIG_VERSION.linux.gtk.x86_64.zip"
fi

if [ -f "$ZIP" ] ; then
   echo "$ZIP has already been downloaded."
else
   wget -c --progress=dot:mega "https://github.com/locationtech/udig-platform/releases/download/release%2F$UDIG_VERSION/$ZIP"
fi
# unpack to /usr/lib/udig
unzip -q "$ZIP" -d "$UDIG_FOLDER"

if [ $? -ne 0 ] ; then
   echo "ERROR: expanding $ZIP"
   exit 1
fi

## Configure Application ##
# allow to execute udig_internal
chmod 775 "$UDIG_FOLDER/udig_internal"

# copy modified startup script for udig
cp "$BUILD_DIR"/../app-conf/udig/udig.sh "$UDIG_FOLDER"

# create link to startup script
ln -s "$UDIG_FOLDER/udig.sh" "$BIN/udig"

# copy desktop icon into the udig folder
cp "$BUILD_DIR"/../app-conf/udig/uDig.desktop "$USER_HOME/Desktop"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/uDig.desktop"


# clean up bundled jre and add jai libs to  openJDK 7 
# see ticket http://trac.osgeo.org/osgeo/ticket/922
# copy jai libs into openjdk lib/ext folder

# cp $UDIG_FOLDER/jre/lib/ext/jai_*.jar $JAVA_INSTALL_FOLDER/lib/ext/
# cp $UDIG_FOLDER/jre/lib/ext/*jai.jar $JAVA_INSTALL_FOLDER/lib/ext/
# cp $UDIG_FOLDER/jre/lib/ext/*jiio.jar $JAVA_INSTALL_FOLDER/lib/ext/
# cp $UDIG_FOLDER/jre/lib/$ARCH/*_jai.so $JAVA_INSTALL_FOLDER/lib/$ARCH/
# cp $UDIG_FOLDER/jre/lib/$ARCH/*_jiio.so $JAVA_INSTALL_FOLDER/lib/$ARCH/

#delete jre folder from udig install folder
# rm -rf $UDIG_FOLDER/jre

## Documentation ##

#copy into /usr/local/share/udig/udig-docs
mkdir -p "$DOCS_FOLDER/udig-docs"

# Download udig's documentation
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

cp uDigWalkthrough1.pdf "$DOCS_FOLDER/udig-docs"
cp uDigWalkthrough2.pdf "$DOCS_FOLDER/udig-docs"

#force eclipse to use mozilla as the default browser (#1394)
echo "-Dorg.eclipse.swt.browser.DefaultType=mozilla" >> /usr/lib/udig/udig_internal.ini

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
