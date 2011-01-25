#!/bin/bash
# Copyright (c) 2009-2010 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will install gvSIG 1.10 (BN1255) using
# a deb package. It will also download the gvSIG manual

# Running:
# =======
# sudo ./install_gvsig.sh

# Important note:
#     You should accept the SUN license for JAI and JAI I/O 
#     binaries installation.

# Changelog:
# ===========
# 2011-01-24:
#   * updated to gvSIG 1.10 final version (BN 1264)
#
# 2010-07-02:
#   * updated to gvSIG 1.10 (BN 1255)
#
# 2010-03-13: 
#   * removed usage of source command
#
# 2010-01-04: adapting the script to 1.9 stable release (jsanz@osgeo.org)
#   * Adapted dependencies
#   * Changed to the "with-jre" version because the Xubuntu 9.10 version
#     doesn't have the packages of Java 1.5


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"

GVSIG_PACKAGE="gvsig_1.10-1264_i386.deb"
GVSIG_PATH="http://gvsig-desktop.forge.osor.eu/downloads/people/scolab/deb"
GVSIG_DOCS="/usr/local/share/gvsig"
GVSIG_MAN="gvSIG-1_1-man-v1-en.pdf"
GVSIG_MAN_URL=http://forge.osor.eu/docman/view.php/89/329/gvSIG-1_1-man-v1-en.pdf

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
TMP="/tmp/build_gvsig"
if [ ! -d $TMP ] ; then
   mkdir "$TMP"
fi
cd "$TMP"

# get deb package 
wget -c --progress=dot:mega "$GVSIG_PATH/$GVSIG_PACKAGE"

# install the deb package
dpkg -i "$GVSIG_PACKAGE"

if [ $? -ne 0 ] ; then
   echo "ERROR: gvsig package failed to install"
   exit 1
fi


rm $TMP/$GVSIG_PACKAGE 

DESKTOP_GIS="$USER_DESKTOP/Desktop GIS"
# place a gvSIG icon on desktop
if [ -d $DESKTOP_GIS ] ; then
   echo "Copying icon to desktop at $DESKTOP_GIS"
   cp /usr/share/applications/gvsig.desktop "$DESTOP_GIS"
fi

# download documentation 
# note: at this time (January 2010) the last updated version of the
#       gvSIG manual is for the 1.1.2 version of gvSIG
if [ -f "$GVSIG_MAN" ]
then
   echo "$GVSIG_MAN has already been downloaded."
else
   wget -c --progress=dot:mega $GVSIG_MAN_URL
fi

if [ ! -d "$GVSIG_DOCS" ] ; then
   mkdir -p "$GVSIG_DOCS"
fi
cp "$GVSIG_MAN" "$GVSIG_DOCS"


# download gvSIG sample project
if [ ! -d "$USER_HOME/gvSIG" ] ; then
   mkdir -p "$USER_HOME/gvSIG"
fi
wget --progress=dot:binary http://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/gvsig/sample-project.gvp \
     --output-document=sample-project.gvp
cp sample-project.gvp "$USER_HOME/gvSIG/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/gvSIG"

echo "gvSIG installation Done!"
