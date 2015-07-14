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
# Version: 2014-12-10
# Author: e.h.juerrens@52north.org, b.pross@52north.org (modified for WPS)
#
# About:
# =====
# This script installs the 52North WPS
#
#
# =============================================================================
# Install script for 52nWPS
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_52nWPS"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat7"
WPS_WAR_INSTALL_FOLDER="/var/lib/tomcat7/webapps"
WPS_BIN_FOLDER="/usr/local/share/52nWPS"
WPS_TAR_NAME="52nWPS-3.3.1.tar.gz"
WPS_TAR_URL="http://52north.org/files/geoprocessing/OSGeoLiveDVD/"
# when changing this, adjust the name in line 215, too,
# and the quickstart, which links to this, too
WPS_WEB_APP_NAME="52nWPS"
WPS_TOMCAT_SCRIPT_NAME="tomcat7"
WPS_ICON_NAME="52n.png"
WPS_URL="http://localhost:8080/$WPS_WEB_APP_NAME"
WPS_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/52nWPS_quickstart.html"
WPS_OVERVIEW_URL="http://localhost/osgeolive/en/overview/52nWPS_overview.html"
# -----------------------------------------------------------------------------
#
echo "[$(date +%M:%S)]: 52nWPS install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "WPS_WAR_INSTALL_FOLDER: $WPS_WAR_INSTALL_FOLDER"
echo "WPS_TAR_NAME: $WPS_TAR_NAME"
echo "WPS_TAR_URL: $WPS_TAR_URL"
echo "WPS_WEB_APP_NAME: $WPS_WEB_APP_NAME"
echo "WPS_TOMCAT_SCRIPT_NAME: $WPS_TOMCAT_SCRIPT_NAME"
echo "WPS_ICON_NAME: $WPS_ICON_NAME"
echo "WPS_URL: $WPS_URL"
echo "WPS_QUICKSTART_URL: $WPS_QUICKSTART_URL"
echo "WPS_OVERVIEW_URL: $WPS_OVERVIEW_URL"
#
#
# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
# 3 tomcat7
#
#
#
# 1 WGET
# It is required to download the 52North WPS package:
#
if [ ! -x "`which wget`" ] ; then
   apt-get install wget
fi
#
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
#
# 3 tomcat7
if [ -f "/etc/init.d/$WPS_TOMCAT_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $WPS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "[$(date +%M:%S)]: $WPS_TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --assume-yes "$WPS_TOMCAT_SCRIPT_NAME" "${WPS_TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
#
#
# =============================================================================
# The 52North WPS installation process
# =============================================================================
# 1 Download and Extract
# 2 tomcat set-up
# 2.0 check for webapps folder in $WPS_WAR_INSTALL_FOLDER
# 2.1 mv war to webapps folder
# 2.2 change owner of war file
#
#
# 1 Download 52nWPS and extract tar.gz
#
# create the TMP directory
mkdir -p "$TMP"
cd "$TMP"
#
# download tar.gz from 52north.org server
if [ -f "$WPS_TAR_NAME" ] ; then
   echo "[$(date +%M:%S)]: $WPS_TAR_NAME has already been downloaded."
   # but was it sucessful?
else
#
#	TODO is this new command working?
#
	rm -v -r "$TMP"/*
   	wget -c --progress=dot:mega "$WPS_TAR_URL$WPS_TAR_NAME"
fi
#
# extract tar, if folders are not there
if [ -f "$WPS_WEB_APP_NAME.war" ] ; then
   echo "[$(date +%M:%S)]: $WPS_WEB_APP_NAME.war has already been extracted."
else
   tar xzf "$WPS_TAR_NAME" --no-same-owner
   echo "[$(date +%M:%S)]: $WPS_TAR_NAME extracted"
fi
#
# copy logo
if [ ! -e "/usr/share/icons/$WPS_ICON_NAME" ] ; then
   chmod 644 "$WPS_ICON_NAME"
   mv -v "$WPS_ICON_NAME" /usr/share/icons/
fi
#
#
# 2.0 check for tomcat webapps folder
#
mkdir -p -v "$WPS_WAR_INSTALL_FOLDER"
#
#
# 2.1 check for tomcat set-up: look for service script in /etc/init.d/
#
if (test ! -d "$WPS_WAR_INSTALL_FOLDER/$WPS_WEB_APP_NAME") then
	mv -v "$TMP/$WPS_WEB_APP_NAME.war" "$WPS_WAR_INSTALL_FOLDER"/
 	chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
	   "$WPS_WAR_INSTALL_FOLDER/$WPS_WEB_APP_NAME.war"
	echo "[$(date +%M:%S)]: $WPS_WEB_APP_NAME installed in tomcat webapps folder"
else
	echo "[$(date +%M:%S)]: $WPS_WEB_APP_NAME already installed in tomcat"
fi

#
#
#
# Startup/Stop scripts set-up
# =============================================================================
mkdir -p "$WPS_BIN_FOLDER"
chgrp users "$WPS_BIN_FOLDER"

if [ ! -e $WPS_BIN_FOLDER/52nWPS-start.sh ] ; then
   cat << EOF > $WPS_BIN_FOLDER/52nWPS-start.sh
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" = "" ]; then
    sudo service tomcat7 start
    (sleep 2; echo "25"; sleep 2; echo "50"; sleep 2; echo "75"; sleep 2; echo "100") | zenity --progress --auto-close --text "52North WPS starting"
fi
firefox $WPS_URL $WPS_QUICKSTART_URL $WPS_OVERVIEW_URL
EOF
fi

if [ ! -e $WPS_BIN_FOLDER/52nWPS-stop.sh ] ; then
   cat << EOF > $WPS_BIN_FOLDER/52nWPS-stop.sh
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" != "" ]; then
    sudo service tomcat7 stop
    zenity --info --text "52North WPS stopped"
fi
EOF
fi

chmod 755 $WPS_BIN_FOLDER/52nWPS-start.sh
chmod 755 $WPS_BIN_FOLDER/52nWPS-stop.sh

#
#
#
# Desktop set-up
# =============================================================================

mkdir -p -v "$USER_HOME/Desktop"

# icon
# Relies on launchassist in home dir
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/52nWPS-start.desktop ] ; then
   cat << EOF > /usr/local/share/applications/52nWPS-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthWPS
Comment=52North WPS
Categories=Geospatial;Servers;
Exec=$WPS_BIN_FOLDER/52nWPS-start.sh
Icon=/usr/share/icons/$WPS_ICON_NAME
Terminal=false
EOF
fi
#
cp -v /usr/local/share/applications/52nWPS-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nWPS-start.desktop"

if [ ! -e /usr/local/share/applications/52nWPS-stop.desktop ] ; then
   cat << EOF > /usr/local/share/applications/52nWPS-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop 52NorthWPS
Comment=52North WPS
Categories=Geospatial;Servers;
Exec=$WPS_BIN_FOLDER/52nWPS-stop.sh
Icon=/usr/share/icons/$WPS_ICON_NAME
Terminal=false
EOF
fi
#
cp -v /usr/local/share/applications/52nWPS-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nWPS-stop.desktop"

#
# We just crossed the finish line
#
####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

