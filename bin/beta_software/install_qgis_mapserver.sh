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
# This script will install qgis_mapserver in xubuntu

# Running:
# =======
# sudo ./install_qgis_mapserver.sh

TMP="/tmp/build_qgis_mapserver"
INSTALL_FOLDER="/usr/local"
DATA_FOLDER="/usr/local/share"
PKG_DATA=$DATA_FOLDER/qgis_mapserver

### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


### setup temp ###
mkdir -p "$TMP"
cd "$TMP"

### Download and unpack qgis_mapserver ###

## get qgis_mapserver
echo "Getting and unpacking qgis_mapserver"

#Dependencies
apt-get install --assume-yes qgis libapache2-mod-fcgid


BASEURL=http://geoserver.sourcepole.ch/
PACKAGE="qgis_mapserver.tgz"

wget -c --progress=dot:mega "$BASEURL/$PACKAGE"
cd /
tar xzf "$TMP/$PACKAGE"

#CGI for testing
ln -s qgis_mapserv.fcgi /usr/lib/cgi-bin/qgis_mapserv

#Sample project
ln -s /usr/local/share/qgis/QGIS-Itasca-Example.qgs /usr/lib/cgi-bin/
