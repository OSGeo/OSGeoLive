#!/bin/sh
#################################################
# 
# Purpose: Installation of openjump into Xubuntu
#  Author:  Stefan Hansen <shansen@lisasoft.com>
#
# Changes:
#  25Jan11  Update script to openJUMP 1.4
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
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
##################################################

# About:
# =====
# This script will install openjump into Xubuntu

# Running:
# =======
# sudo ./install_openjump.sh


TMP="/tmp/build_openjump"
INSTALL_FOLDER="/usr/lib"
DATA_FOLDER="/usr/local/share"
OJ_FOLDER="$INSTALL_FOLDER/openjump-1.4.0"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

## Setup things... ##
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir -p "$TMP"
cd "$TMP"


## Install Application ##

# get openjump
if [ -f "openjump-v1.4.zip" ]
then
   echo "openjump-v1.4.zip has already been downloaded."
else
   wget -c --progress=dot:mega \
http://downloads.sourceforge.net/project/jump-pilot/OpenJUMP/1.4/openjump-1.4.zip
fi
# unpack it and copy it to /usr/lib
unzip -q openjump-1.4.zip -d $INSTALL_FOLDER

## Configure Application ##

# Download desktop icon
if [ -f "openjump.sh" ] ; then
   echo "openjump.sh has already been downloaded."
else
   echo "FIXME: don't use wget for local files, just copy from local svn checkout."
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_0/app-conf/openjump/openjump.sh
fi
# copy it into the openjump folder
cp openjump.sh $OJ_FOLDER/bin
#make startup script executable
chmod 755 $OJ_FOLDER/bin/openjump.sh
# create link to startup script
ln -s $OJ_FOLDER/bin/openjump.sh /usr/bin/openjump

#copy config-files to user's home
mkdir $USER_HOME/.jump
cp $OJ_FOLDER/bin/workbench-properties.xml $USER_HOME/.jump
chown $USER_NAME:$USER_NAME $USER_HOME/.jump
chown $USER_NAME:$USER_NAME $USER_HOME/.jump/workbench-properties.xml

# Download desktop icon
if [ -f openjump.ico ] ; then
   echo "openjump.icon has already been downloaded."
else
   echo "FIXME: don't use wget for local files, just copy from local svn checkout."
   wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_0/app-conf/openjump/openjump.ico \
       -O openjump.ico
fi
# copy it into the openjump folder
cp openjump.ico "$OJ_FOLDER"

# Download desktop link
echo "FIXME: don't use wget for local files, just copy from local svn checkout."
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_0/app-conf/openjump/openjump.desktop \
   -O openjump.desktop
# copy it into the openjump folder
cp openjump.desktop $USER_HOME/Desktop
chown $USER_NAME:$USER_NAME $USER_HOME/Desktop/openjump.desktop


## Sample Data ##

# Download openjump's sample data
if [ -f "ogrs2009_tutorialddata_mod.zip" ]
then
   echo "ogrs2009_tutorialddata_mod.zip has already been downloaded."
else
   wget -c --progress=dot:mega -O ogrs2009_tutorialddata_mod.zip \
http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.3%20Docs%20%28English%29/ogrs2009_tutorialddata_mod.zip/download
fi
#unzip the file into /usr/local/share/openjump/data
mkdir -p "$DATA_FOLDER/openjump/data"
unzip -q ogrs2009_tutorialddata_mod.zip -d "$DATA_FOLDER/openjump/data/"


## Documentation ##

# Download openjump's documentation
if [ -f "ogrs2009_tutorial.pdf" ]
then
   echo "ogrs2009_tutorial.pdf has already been downloaded."
else
   wget -c --progress=dot:mega -O ogrs2009_tutorial.pdf \
http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.3%20Docs%20%28English%29/ogrs2009_tutorial.pdf/download
fi

#copy into /usr/local/share/openjump/docs
mkdir -p "$DATA_FOLDER/openjump/docs"
cp ogrs2009_tutorial.pdf "$DATA_FOLDER/openjump/docs/"

