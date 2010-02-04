#!/bin/sh
#################################################
# 
# Purpose: Installation of Kosmo into Xubuntu
# Author:  Sergio Banos Calvo <sbc@saig.es> - SAIG <info@saig.es>
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2010 SAIG
#
# Licensed under the GNU GPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, either
# in the "LICENSE.GPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/gpl.html".
##################################################

# About:
# =====
# This script will install Kosmo 2.0 RC1 into Xubuntu

# Running:
# =======
# sudo ./install_kosmo.sh

USER_NAME="user"
TMP="/tmp/build_kosmo"
INSTALL_FOLDER="/usr/lib"
KOSMO_FOLDER="$INSTALL_FOLDER/kosmo_2.0_RC1"
BIN="/usr/bin"
USER_HOME="/home/$USER_NAME"

## Setup things... ##

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir $TMP
cd $TMP

## Install Application ##

# get kosmo
wget -c --progress=dot:mega http://www.opengis.es/descargas/Kosmo_Desktop_2.0_RC1_linux_jre.tar.gz

# unpack it and copy it to /usr/lib
tar xzf Kosmo_Desktop_2.0_RC1_linux_jre.tar.gz -C $INSTALL_FOLDER
chmod -R 777 $KOSMO_FOLDER

## execute the links.sh script
cd $KOSMO_FOLDER/libs
./links.sh
cd $TMP

# get correct kosmo.sh
rm $KOSMO_FOLDER/bin/Kosmo.sh
wget -c --progress=dot:mega http://www.opengis.es/descargas/Kosmo.sh
cp Kosmo.sh $KOSMO_FOLDER/bin/
chown $USER_NAME:$USER_NAME $KOSMO_FOLDER/bin/Kosmo.sh
chmod 777 $KOSMO_FOLDER/bin/Kosmo.sh

# create link to startup script
ln -s $KOSMO_FOLDER/bin/Kosmo.sh /usr/bin/kosmo_2.0_RC1

# Download desktop link
wget -nv http://www.opengis.es/descargas/Kosmo_2.0_RC1.desktop

# copy it into the Kosmo_2.0_RC1 folder
cp Kosmo_2.0_RC1.desktop $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/Kosmo_2.0_RC1.desktop
chmod 777 $USER_HOME/Desktop/Kosmo_2.0_RC1.desktop


