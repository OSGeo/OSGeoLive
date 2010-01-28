#!/bin/sh
#################################################
# 
# Purpose: Installation of Kosmo into Xubuntu
# Author:  SAIG <info@saig.es>
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2009 SAIG
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
# This script will install Kosmo 1.2.1 into Xubuntu

# Running:
# =======
# sudo ./install_kosmo.sh

USER_NAME="user"
TMP="/tmp/build_kosmo"
INSTALL_FOLDER="/usr/lib"
KOSMO_FOLDER="$INSTALL_FOLDER/kosmo_1_2_1"
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
wget -c --progress=dot:mega http://www.saig.es/descargas/dloads/kosmo/kosmo_1_2_1_linux_jre.tar.gz

# unpack it and copy it to /usr/lib
tar xzf kosmo_1_2_1_linux_jre.tar.gz -C $INSTALL_FOLDER
chmod -R 755 $KOSMO_FOLDER

# create link to startup script
ln -s $KOSMO_FOLDER/bin/Kosmo.sh /usr/bin/kosmo_1_2_1

# Download desktop link
wget -nv http://www.saig.es/descargas/dloads/kosmo/kosmo_1_2_1.desktop

# copy it into the openjump folder
cp kosmo_1_2_1.desktop $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/kosmo_1_2_1.desktop
