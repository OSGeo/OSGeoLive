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
# This script will install gvSIG 1.9 (BN1253) using
# a deb package. It will also download the gvSIG manual

# Running:
# =======
# sudo ./install_gvsig.sh

# Changelog:
# ===========
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
GVSIG_PACKAGE="gvsig-withjre_1.9.0-1253_i386.deb"
GVSIG_PATH="http://gvsig-desktop.forge.osor.eu/downloads/people/iver"
GVSIG_DOCS="/usr/local/share/gvsig"
GVSIG_MAN="gvSIG-1_1-man-v1-en.pdf"

# load user dirs to have the  $XDG_DESKTOP_DIR variable
if [ -f "$USER_HOME/.config/user-dirs.dirs" ]
then
   . "$USER_HOME/.config/user-dirs.dirs"
   USER_DESKTOP="$XDG_DESKTOP_DIR"
   echo "\n\n$USER_DESKTOP\n\n"
else
   USER_DESKTOP="$USER_HOME/Desktop"
fi

#failsafe
if [ -z "$USER_DESKTOP" ] ; then
   USER_DESKTOP="$USER_HOME/Desktop"
fi



# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# install dependencies
apt-get --assume-yes install libgdal1-1.6.0

# create tmp folders
TMP="/tmp/build_gvsig"
if [ ! -d $TMP ] ; then
   mkdir "$TMP"
fi
cd "$TMP"

# get deb package with the jre "gvsig-withjre"
if [ -f "$GVSIG_PACKAGE" ]
then
   echo "$GVSIG_PACKAGE has already been downloaded."
else
   wget -c --progress=dot:mega "$GVSIG_PATH/$GVSIG_PACKAGE"
fi


###### currently broken (wants dropped gdal 1.5.0)
echo "ERROR: gvSIG package is out of date for Ubuntu Lucid. Needs to depend on newer version of GDAL."
exit 1
######

# install the deb package
dpkg -i "$GVSIG_PACKAGE"


if [ $? -ne 0 ] ; then
   echo "ERROR: gvsig package failed to install"
   exit 1
fi

# place a gvSIG icon on desktop
if [ -d $USER_DESKTOP ] ; then
   echo "Copying icon to desktop at $USER_DESKTOP"
   cp /usr/share/applications/gvsig.desktop "$USER_DESKTOP"
fi

# download documentation 
# note: at this time (January 2010) the last updated version of the
#       gvSIG manual is for the 1.1.2 version of gvSIG
if [ -f "$GVSIG_MAN" ]
then
   echo "$GVSIG_MAN has already been downloaded."
else
   wget -c --progress=dot:mega "http://forge.osor.eu/docman/view.php/89/329/gvSIG-1_1-man-v1-en.pdf"
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


echo "gvSIG Done!"
