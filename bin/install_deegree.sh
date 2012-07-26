#!/bin/bash
#################################################################################
#
# Purpose: Installation of deegree-webservices-3.2-pre9 into Xubuntu
# Author:  Judit Mays <mays@lat-lon.de>, Johannes Kuepper <kuepper@lat-lon.de>
# Credits: Stefan Hansen <shansen@lisasoft.com>
#          H.Bowman <hamish_b  yahoo com>
# Date:    $Date$
# Revision:$Revision$
#
#################################################################################
# Copyright (c) 2009-2012 lat/lon GmbH
# Copyright (c) 2009-2012 Uni Bonn
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
#################################################################################

# About:
# =====
# This script will install deegree-webservices (with included Tomcat) into Xubuntu
#
# deegree webservices version 3.2-pre9 runs with openjdk7 on Apache Tomcat 6.0.35
#

# Running:
# =======
# sudo ./install_deegree.sh

###########################

TMP="/tmp/build_deegree"
INSTALL_FOLDER="/usr/local/lib"
DEEGREE_FOLDER="$INSTALL_FOLDER/deegree-webservices-3.2-pre9"
DEEGREE_WORKSPACE_ROOT="/usr/local/share/deegree"
BIN="/usr/local/bin"

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
PASSWORD="user"
BUILD_DIR=`pwd`
TOMCAT_PORT=8033

## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again."
   exit 1
fi
if [ ! -x "`which java`" ] ; then
   echo "ERROR: java is required, please install it and try again."
   exit 1
fi

## create tmp folder
BUILD_DIR=`pwd`
mkdir -p "$TMP"
cd "$TMP"

## download required stuff into tmp folder
wget -N --progress=dot:mega \
   "http://artefacts.deegree.org/libs-releases-local/org/deegree/deegree-webservices/3.2-pre9/deegree-webservices-3.2-pre9.zip"
wget -N --progress=dot:mega \
   "http://artefacts.deegree.org/libs-releases-local/org/deegree/deegree-workspace-inspire/3.2-pre9/deegree-workspace-inspire-3.2-pre9.deegree-workspace"

cp "$BUILD_DIR"/../app-conf/deegree/deegree_start.sh .
cp "$BUILD_DIR"/../app-conf/deegree/deegree_stop.sh .

### Install deegree-webservices (with included Tomcat) ###

## unpack as root
cd "$TMP"
unzip -q deegree-webservices-3.2-pre9.zip
mv deegree-webservices-3.2-pre9 "$INSTALL_FOLDER"
# "user" must not own files outside of /home
# do "chmod g+w; chgrp users" if needed, but only on stuff that really needs it
#chown -R $USER_NAME:$USER_NAME "$DEEGREE_FOLDER"

### Configure Application ###

## Copy startup script for deegree
cp $TMP/deegree_start.sh $BIN
cp $TMP/deegree_stop.sh $BIN
chmod 755 "$BIN"/deegree_st*.sh

### install desktop icons ##
if [ ! -e "/usr/share/icons/deegree_desktop_48x48.png" ] ; then
   wget -nv "http://download.deegree.org/LiveDVD/FOSS4G2012/deegree_desktop_48x48.png"
   mv deegree_desktop_48x48.png /usr/share/icons/
fi

if(test ! -d $USER_HOME/Desktop) then
    mkdir $USER_HOME/Desktop
fi

## start icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-start.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start deegree
Comment=deegree webservices 3.2-pre9
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/bin/launchassist.sh $BIN/deegree_start.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-start.desktop"

## stop icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop deegree
Comment=deegree webservices 3.2-pre9
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/bin/launchassist.sh  $BIN/deegree_stop.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-stop.desktop"

## Adapt Tomcat ports
cd "$DEEGREE_FOLDER"
echo "Fixing Tomcat default ports (8080 -> $TOMCAT_PORT, 8005 -> 8006, 8443 -> 8444) in server.xml"
sed -i -e "s/8080/$TOMCAT_PORT/" \
       -e 's/8005/8006/' \
       -e 's/8443/8444/' \
   conf/server.xml


cd webapps/ROOT/
FILES_TO_EDIT="
console/wms/js/sextante.js
console/wps/openlayers-demo/proxy.jsp
console/wps/openlayers-demo/sextante.js"

sed -i -e "s/localhost:8080/localhost:$TOMCAT_PORT/g" \
       -e "s/127.0.0.1:8080/127.0.0.1:$TOMCAT_PORT/g" \
   $FILES_TO_EDIT


## create DEEGREE_WORKSPACE_ROOT
rm -Rf "$DEEGREE_WORKSPACE_ROOT"
mkdir -p "$DEEGREE_WORKSPACE_ROOT"

## Extract INSPIRE workspace in DEEGREE_WORKSPACE_ROOT
cd "$DEEGREE_WORKSPACE_ROOT"
mkdir deegree-workspace-inspire-3.2-pre9
cd deegree-workspace-inspire-3.2-pre9
unzip -q "$TMP"/deegree-workspace-inspire-3.2-pre9.deegree-workspace

## Fix permissions
# "user" must not own files outside of /home
#chown -R $USER_NAME:$USER_NAME "$DEEGREE_WORKSPACE_ROOT"
chmod g+w "$DEEGREE_WORKSPACE_ROOT" -R
chgrp users "$DEEGREE_WORKSPACE_ROOT" -R
