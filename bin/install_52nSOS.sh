#!/bin/sh
# Copyright (c) 2011 The Open Source Geospatial Foundation.
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
#
# Version: 2014-06-17
# Author: e.h.juerrens@52north.org
# TODO
# - check new version
#
# About:
# =====
# This script installs 52nSOS
#
#
# =============================================================================
# Install script for 52nSOS
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_52nSOS"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat6"
SOS_TOMCAT_SCRIPT_NAME="tomcat6"
SOS_WEB_APP_NAME="52nSOS"
SOS_ICON_NAME="52nSOS.png"
SOS_URL="http://localhost:8080/$SOS_WEB_APP_NAME"
SOS_QUICKSTART_URL="http://localhost/en/quickstart/52nSOS_quickstart.html"
SOS_OVERVIEW_URL="http://localhost/en/overview/52nSOS_overview.html"
SOS_WAR_INSTALL_FOLDER="/var/lib/$SOS_TOMCAT_SCRIPT_NAME/webapps"
SOS_INSTALL_FOLDER="/usr/local/52nSOS"
SOS_BIN_FOLDER="/usr/local/share/52nSOS"
SOS_TAR_NAME="52n-sensorweb-sos-osgeolive-8.0.tar.gz"
SOS_TAR_URL="http://52north.org/files/security/osgeo-live/"
# -----------------------------------------------------------------------------
#
echo "[$(date +%M:%S)]: 52nSOS install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "SOS_WAR_INSTALL_FOLDER: $SOS_WAR_INSTALL_FOLDER"
echo "SOS_INSTALL_FOLDER: $SOS_INSTALL_FOLDER"
echo "SOS_TAR_NAME: $SOS_TAR_NAME"
echo "SOS_TAR_URL: $SOS_TAR_URL"
echo "SOS_WEB_APP_NAME: $SOS_WEB_APP_NAME"
echo "SOS_TOMCAT_SCRIPT_NAME: $SOS_TOMCAT_SCRIPT_NAME"
echo "SOS_ICON_NAME: $SOS_ICON_NAME"
echo "SOS_URL: $SOS_URL"
echo "SOS_QUICKSTART_URL: $SOS_QUICKSTART_URL"
echo "SOS_OVERVIEW_URL: $SOS_OVERVIEW_URL"
#
#
# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
# 3 tomcat6
#
# 1 WGET
# It is required to download the 52North SOS package:
#
if [ ! -x "`which wget`" ] ; then
   apt-get install wget
fi
#
#
# 2 Check for OpenJDK
#
if [ ! -x "`which java`" ] ; then
	apt-get -q update
	#
	apt-get --assume-yes install openjdk-7-jre
fi
#
#
# 3 tomcat6
#
if [ -f "/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $SOS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "[$(date +%M:%S)]: $SOS_TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --assume-yes "$SOS_TOMCAT_SCRIPT_NAME" "${SOS_TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
# =============================================================================
# The 52North SOS installation process
# =============================================================================
# 1 Download and Extract
# 2 tomcat set-up
# 2.0 check for webapps folder in $SOS_WAR_INSTALL_FOLDER
# 2.1 mv war to webapps folder
# 2.2 change owner of war file
#
#
# 1 Download 52nSOS and extract tar.gz
#
# create the TMP directory
mkdir -p "$TMP"
cd "$TMP"
#
# download tar.gz from 52north.org server
rm -v -r "$TMP"/*
wget -c --progress=dot:mega "$SOS_TAR_URL$SOS_TAR_NAME"
#
# extract tar, if folders are not there
tar xzf "$SOS_TAR_NAME"
echo "[$(date +%M:%S)]: $SOS_TAR_NAME extracted"
#
# copy logo
mkdir -p /usr/local/share/icons
if [ ! -e "/usr/local/share/icons/$SOS_ICON_NAME" ] ; then
   chmod 644 "$SOS_ICON_NAME"
   mv -v "$SOS_ICON_NAME" /usr/local/share/icons/
fi
#
#
# 2.0 check for tomcat webapps folder
#
mkdir -p -v "$SOS_WAR_INSTALL_FOLDER"
#
#
# 2.1 check for webapp set-up
#
if (test ! -d "$SOS_WAR_INSTALL_FOLDER/$SOS_WEB_APP_NAME") then
	mv -v "$TMP/$SOS_WEB_APP_NAME.war" "$SOS_WAR_INSTALL_FOLDER"/
 	chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
	   "$SOS_WAR_INSTALL_FOLDER/$SOS_WEB_APP_NAME.war"
	echo "[$(date +%M:%S)]: $SOS_WEB_APP_NAME installed in tomcat webapps folder"
else
	echo "[$(date +%M:%S)]: $SOS_WEB_APP_NAME already installed in tomcat"
fi
#
#
#
# Startup/Stop scripts set-up
# =============================================================================
mkdir -p "$SOS_BIN_FOLDER"
chgrp users "$SOS_BIN_FOLDER"

if [ ! -e $SOS_BIN_FOLDER/52nSOS-start.sh ] ; then
   cat << EOF > $SOS_BIN_FOLDER/52nSOS-start.sh
#!/bin/bash
STAT=\`sudo service tomcat6 status | grep pid\`
if [ "\$STAT" = "" ]; then
    sudo service tomcat6 start
    (sleep 2; echo "25"; sleep 2; echo "50"; sleep 2; echo "75"; sleep 2; echo "100") | zenity --progress --auto-close --text "52North SOS starting"
fi
firefox $SOS_URL $SOS_QUICKSTART_URL $SOS_OVERVIEW_URL
EOF
fi
#
if [ ! -e $SOS_BIN_FOLDER/52nSOS-stop.sh ] ; then
   cat << EOF > $SOS_BIN_FOLDER/52nSOS-stop.sh
#!/bin/bash
STAT=\`sudo service tomcat6 status | grep pid\`
if [ "\$STAT" != "" ]; then
    sudo service tomcat6 stop
    zenity --info --text "52North SOS stopped"
fi
EOF
fi
#
chmod 755 $SOS_BIN_FOLDER/52nSOS-start.sh
chmod 755 $SOS_BIN_FOLDER/52nSOS-stop.sh
#
#
# Desktop set-up
# =============================================================================
mkdir -p -v "$USER_HOME/Desktop"
#
# icon
# Relies on launchassist in home dir
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/52nSOS-start.desktop ] ; then
   cat << EOF > /usr/local/share/applications/52nSOS-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthSOS
Comment=52North SOS
Categories=Geospatial;Servers;
Exec=$SOS_BIN_FOLDER/52nSOS-start.sh
Icon=/usr/local/share/icons/$SOS_ICON_NAME
Terminal=false
EOF
fi
#
#
cp -v /usr/local/share/applications/52nSOS-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-start.desktop"
#
if [ ! -e /usr/local/share/applications/52nSOS-stop.desktop ] ; then
   cat << EOF > /usr/local/share/applications/52nSOS-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop 52NorthSOS
Comment=52North SOS
Categories=Geospatial;Servers;
Exec=$SOS_BIN_FOLDER/52nSOS-stop.sh
Icon=/usr/local/share/icons/$SOS_ICON_NAME
Terminal=false
EOF
fi
#
cp -v /usr/local/share/applications/52nSOS-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-stop.desktop"
#
#
# We just crossed the finish line
#
####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
