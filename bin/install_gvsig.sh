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
# 2011-07-03:
#   * updated to gvSIG 1.11, removed docs (BN 1305)
#
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
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop" 

GVSIG_PACKAGE="gvsig_1.11-1305_i386.deb"
GVSIG_PATH="http://test.scolab.es/pub/gvSIG"

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
if [ ! -e $GVSIG_PACKAGE ] ; then
   wget --progress=dot:mega "$GVSIG_PATH/$GVSIG_PACKAGE"
fi

# remove it if it's present at the system
echo "Purging previous versions of gvSIG"
apt-get -y purge gvsig

# install the deb package
echo "Installing gvSIG package"
dpkg -i "$GVSIG_PACKAGE"

if [ $? -ne 0 ] ; then
   echo "ERROR: gvsig package failed to install"
   exit 1
fi

rm $TMP/$GVSIG_PACKAGE 

# place a gvSIG icon on desktop
if [ -d $USER_DESKTOP ] ; then
   echo "Copying icon to desktop at $USER_DESKTOP"
   cp /usr/share/applications/gvsig.desktop "$USER_DESKTOP"
   chown $USER_NAME:$USER_NAME "$USER_DESKTOP/gvsig.desktop"
   chmod +x "$USER_DESKTOP/gvsig.desktop"   
fi

echo "Creating the gvSIG folder with a custom config and sample project"
if [ -d "$USER_HOME/gvSIG" ] ; then
   rm -rf "$USER_HOME/gvSIG"
fi
mkdir -p  "$USER_HOME/gvSIG"

# download gvSIG sample project
wget --progress=dot:binary http://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/gvsig/sample-project.gvp \
     --output-document="$USER_HOME/gvSIG/sample-project.gvp"

# download and set up default andami config
wget --progress=dot:binary http://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/gvsig/andami-config.xml \
     --output-document="$USER_HOME/gvSIG/andami-config.xml"

chown -R $USER_NAME:$USER_NAME "$USER_HOME/gvSIG"

# download and set up a custom startup script
wget --progress=dot:binary http://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/gvsig/gvSIG.sh \
     --output-document="/opt/gvSIG_1.11/bin/gvSIG.sh"


echo "gvSIG installation Done!"
