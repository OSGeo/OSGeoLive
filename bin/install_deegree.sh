#!/bin/sh
#################################################################################
# 
# Purpose: Installation of deegree_2.2-with-tomcat_6.0.20-all-in-one into Xubuntu
# Author:  Judit Mays <mays@lat-lon.de>
# Credits: Stefan Hansen <shansen@lisasoft.com>
#          H.Bowman <hamish_b  yahoo com>
#
#################################################################################
# Copyright (c) 2009 lat/lon GmbH
# Copyright (c) 2009 Uni Bonn
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
# This script will install deegree-tomcat-all-in-one into Xubuntu

# Running:
# =======
# sudo ./install_deegree.sh

###########################

TMP="/tmp/deegree_downloads"
INSTALL_FOLDER="/usr/lib"
DEEGREE_FOLDER="$INSTALL_FOLDER/deegree-2.2_tomcat-6.0.20"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
## create tmp folders
mkdir $TMP
cd $TMP


### Install Application ###

## get deegree-tomcat-all-in-one
if [ -f "deegree-2.2_tomcat-6.0.20.tar.gz" ]
then
   echo "deegree-2.2_tomcat-6.0.20.tar.gz has already been downloaded."
else
   wget http://download.deegree.org/LiveDVD/FOSS4G2009/deegree-2.2_tomcat-6.0.20.tar.gz
fi
## unpack it to /usr/lib
tar -xzf deegree-2.2_tomcat-6.0.20.tar.gz -C $INSTALL_FOLDER


### Configure Application ###

## Download startup script for deegree ##
if [ -f "deegree_start.sh" ]
then
   echo "deegree_start.sh has already been downloaded."
else
   wget http://download.deegree.org/LiveDVD/FOSS4G2009/deegree_start.sh
fi
## copy it into the /usr/bin folder
cp deegree_start.sh $BIN

## Download shutdown script for deegree ##
if [ -f "deegree_stop.sh" ]
then
   echo "deegree_stop.sh has already been downloaded."
else
   wget http://download.deegree.org/LiveDVD/FOSS4G2009/deegree_stop.sh
fi
## copy it into the /usr/bin folder
cp deegree_stop.sh $BIN

## make executable
chmod 755 $BIN/deegree_st*.sh


### install desktop icons ##
# deleted "\mv grass64.xpm /usr/share/icons/" from "if"
# hope something like this is not needed...
if [ ! -e "/usr/share/icons/deegree_desktop_48x48.png" ] ; then
   wget "http://download.deegree.org/LiveDVD/FOSS4G2009/deegree_desktop_48x48.png" 
   \mv deegree_desktop_48x48.png /usr/share/icons/
fi

## start icon
if [ ! -e /usr/share/applications/deegree-start.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=start deegree
Comment=deegree v2.2
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/deegree_start.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=true
EOF
fi

cp -a /usr/share/applications/deegree-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-start.desktop"

## stop icon
if [ ! -e /usr/share/applications/deegree-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=stop deegree
Comment=deegree v2.2
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/deegree_stop.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=true
EOF
fi

cp -a /usr/share/applications/deegree-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-stop.desktop"


