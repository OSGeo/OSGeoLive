#!/bin/sh
#################################################
# 
# Purpose: Installation of Kosmo into Xubuntu
# Author:  SAIG <info@saig.es>
#
#################################################
# Copyright (c) 2009 Open Source Geospatial Foundation (OSGeo)
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
# This script will install Kosmo into Xubuntu

# Running:
# =======
# sudo ./install_kosmo.sh

echo TYPE YOUR USER NAME:
read USER_NAME
TMP="/tmp/kosmo_downloads"
INSTALL_FOLDER="/usr/lib"
KOSMO_FOLDER="$INSTALL_FOLDER/kosmo_2_0_beta"
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
if [ -f "kosmo_2_0_beta_linux_jre_2009_09_07.tar.gz" ]
then
   echo "Kosmo_2_0_beta has already been downloaded."
else
   wget http://www.saig.es/descargas/dloads/kosmo/kosmo_2_0_beta_linux_jre_2009_09_07.tar.gz
fi

# unpack it and copy it to /usr/lib
tar xvfz kosmo_2_0_beta_linux_jre_2009_09_07.tar.gz -C $INSTALL_FOLDER
chmod -R 755 $KOSMO_FOLDER

# create link to startup script
ln -s $KOSMO_FOLDER/bin/Kosmo.sh /usr/bin/kosmo_2_0_beta

# generate the library dynamic links
cd $KOSMO_FOLDER/libs
./links.sh
cd $TMP

# Download desktop link
if [ -f "kosmo_2_0_beta.desktop" ]
then
   echo "kosmo_2_0_beta.desktop has already been downloaded."
else
   wget http://www.saig.es/descargas/dloads/kosmo/kosmo_2_0_beta.desktop
fi

# copy it into the Desktop folder
cp kosmo_2_0_beta.desktop $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/kosmo_2_0_beta.desktop



