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
# This script will install 52nWPS
# =============================================================================
# Install script for 52nWPS
# =============================================================================
TMP="/tmp/build_52nWPS"
INSTALL_FOLDER="/usr/local"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
BUILD_DIR=`pwd`
# =============================================================================
# Pre install checks
# =============================================================================
# WGET is required to download the Geomajas package:
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi



##### Java Sun JDK 6 is required:
# but not available
#if [ ! -x "`which java`" ] ; then
#   add-apt-repository "deb http://archive.canonical.com/ precise partner"
#   apt-get update
#
#   apt-get --assume-yes remove openjdk-6-jre
#   apt-get --assume-yes install java-common sun-java6-bin sun-java6-jre sun-java6-jdk
#   echo export JAVA_HOME=/usr/lib/jvm/java-6-sun >> ~/.bashrc
#fi



##### Create the TMP directory
mkdir -p "$TMP"
cd "$TMP"


# =============================================================================
# The 52nWPS installation process
# =============================================================================


##### Step1 and Step2: Download 52nWPS 

if [ -f "52n-wps-rc6.tar.gz" ]
then
   echo "52n-wps-rc6.tar.gz has already been downloaded."
else
   wget -c --progress=dot:mega \
      "http://52north.org/files/geoprocessing/OSGeoLiveDVD/52n-wps-rc6.tar.gz"
fi

tar xzf 52n-wps-rc6.tar.gz

if [ ! -e "$INSTALL_FOLDER" ] ; then
   mkdir -p "$INSTALL_FOLDER" --verbose
fi


cp -R $TMP/52nWPS "$INSTALL_FOLDER"/


if [ ! -e "/usr/share/icons/52n.png" ] ; then
  cp $INSTALL_FOLDER/52nWPS/52n.png /usr/share/icons/
fi

mkdir -p -v "$USER_HOME/Desktop"

## start icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/52n-start.desktop ] ; then
   cat << EOF > /usr/share/applications/52n-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthWPS
Comment=52North WPS 2.0RC6 
Categories=Geospatial;Servers;
Exec=dash $INSTALL_FOLDER/52nWPS/52n-start.sh
Icon=/usr/share/icons/52n.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/52n-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52n-start.desktop"

## stop icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/52n-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/52n-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop 52NorthWPS
Comment=52North WPS 2.0RC6
Categories=Geospatial;Servers;
Exec=dash $INSTALL_FOLDER/52nWPS/tomcat6/apache-tomcat-6.0.26/bin/shutdown.sh
Icon=/usr/share/icons/52n.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/52n-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52n-stop.desktop"
chown -R $USER_NAME:$USER_NAME $INSTALL_FOLDER/52nWPS/


# something screwed up with the ISO permissions:
chgrp tomcat6 /usr/local/52nWPS/tomcat6/apache-tomcat-6.0.26/bin/*.sh


# upstream's startup script had quoting issues, replace it:
echo
 diff -u /usr/local/52nWPS/52n-start.sh "$BUILD_DIR"/../app-conf/52n/52nWPS-start.sh
echo
cp -f "$BUILD_DIR"/../app-conf/52n/52nWPS-start.sh /usr/local/52nWPS/52n-start.sh
