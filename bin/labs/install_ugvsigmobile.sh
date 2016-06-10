#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install 'Unofficial gvSIG Mobile for Linux devices'
# using a .deb file. It will also download some documentation

# Running:
# =======
#
# cd beta_software
# sudo ./ugvsigmobile.sh
# (in this case, the start menu will be in the "Applications - Education" menu)
#
# should be called with sudo ./install_beta_and_submenu.sh
#

# --------------- Start: ---------------------

# install dependencies. gpsd is also as a dep. in the deb file
apt-get --assume-yes install gpsd 

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


# create tmp folders
TMP="/tmp/build_ugvsigmobile"

if [ ! -d $TMP ] ; then
   mkdir "$TMP"
fi

cd "$TMP"

# get deb package
UGM_PACKAGE="ugvsigmobile_0.1.6_all.deb"
UGM_BASEURL="https://garage.maemo.org/frs/download.php/7362"

if [ -f "$UGM_PACKAGE" ]
then
   echo "$UGM_PACKAGE has already been downloaded."
else
   wget -nv --no-check-certificate "$UGM_BASEURL/$UGM_PACKAGE"
fi

# install the deb package
dpkg -i "$UGM_PACKAGE"

if [ $? -ne 0 ] ; then
   echo "ERROR: ugvsigmobile package failed to install!"
   exit 1
fi

# download documentation
UGVSIGMOBILE_DOCS=/usr/local/share/ugvsigmobile
UGVSIGMOBILE_DOCZIP=ugvsigmobile_0.1.6_doc_en_it.zip

if [ -f "$UGVSIGMOBILE_DOCZIP" ]
then
   echo "$UGVSIGMOBILE_DOCZIP has already been downloaded."
else
   wget -nv --no-check-certificate "https://garage.maemo.org/frs/download.php/7632/$UGVSIGMOBILE_DOCZIP"
fi

if [ ! -d "$UGVSIGMOBILE_DOCS" ]
then
   mkdir -p "$UGVSIGMOBILE_DOCS"
else
   rm "$UGVSIGMOBILE_DOCS"/*.pdf
   rm "$UGVSIGMOBILE_DOCS"/*.zip
   rm "$UGVSIGMOBILE_DOCS"/*.shx
   rm "$UGVSIGMOBILE_DOCS"/*.dbf
   rm "$UGVSIGMOBILE_DOCS"/*.shp
fi

cp "$UGVSIGMOBILE_DOCZIP" "$UGVSIGMOBILE_DOCS"

cd "$UGVSIGMOBILE_DOCS"
unzip "$UGVSIGMOBILE_DOCZIP"

echo "Done!"
