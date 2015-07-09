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
# Version: 2011-06-30
# Author: j.drewnak@52north.org
# TODO
#
# About:
# =====
# This script installs 52n WSS
#
#
# =============================================================================
# Install script for 52n WSS
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
./diskspace_probe.sh "`basename $0`" begin
####

TMP="/tmp/build_52nWSS"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BIN="/usr/local/bin"
TOMCAT_USER_NAME="tomcat7"
WSS_WAR_INSTALL_FOLDER="/var/lib/tomcat7/webapps"
WSS_INSTALL_FOLDER="/usr/local/52nWSS"
WSS_BIN_FOLDER="/usr/local/share/52nWSS"
WSS_TAR_NAME="52n-wss-osgeo-live.tar.gz"
WSS_TAR_URL="http://52north.org/files/security/osgeo-live"
WSS_WEBAPP_CONTEXT="wss"
WSS_WAR_NAME="wss";
WSS_TOMCAT_SCRIPT_NAME="tomcat7"
WSS_DESKTOP_STARTER_NAME="52nWSS-start.desktop"
WSS_DESKTOP_STOPER_NAME="52nWSS-stop.desktop"
WSS_ICON_NAME="52nWSS.png"
WSS_URL="http://localhost:8080/wss/"
WSS_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/52nWSS_quickstart.html"
WSS_OVERVIEW_URL="http://localhost/osgeolive/en/overview/52nWSS_overview.html"
# -----------------------------------------------------------------------------
#
echo "52nWSS install started"
if [ -n "$DEBUG" ] ; then
   echo "$TMP"
   echo "$USER_NAME"
   echo "$USER_HOME"
   echo "$TOMCAT_USER_NAME"
   echo "$WSS_WAR_INSTALL_FOLDER"
   echo "$WSS_INSTALL_FOLDER"
   echo "$WSS_TAR_NAME"
   echo "$WSS_TAR_URL"
   echo "$WSS_WEBAPP_CONTEXT"
   echo "$WSS_WAR_NAME"
   echo "$WSS_TOMCAT_SCRIPT_NAME"
   echo "$WSS_ICON_NAME"
   echo "$WSS_DESKTOP_STARTER_NAME"
   echo "$WSS_URL"
   echo "$WSS_QUICKSTART_URL"
   echo "$WSS_OVERVIEW_URL"
fi

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
# It is required to download the 52North WSS package:
#
if [ ! -x "`which wget`" ] ; then
   apt-get install wget
fi
#
#
#
# 2 Java Sun JDK 6 is required:
#
if [ ! -x "`which java`" ] ; then
	apt-get -q update
	#
	apt-get --assume-yes remove openjdk-6-jre
	apt-get --assume-yes install java-common sun-java6-bin sun-java6-jre sun-java6-jdk
	# this should probably be taken care of system-wide in /etc/rc.local if not already:
	echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun" >> ~/.bashrc
fi
#
#
#
# 3 tomcat7
if [ -f "/etc/init.d/$WSS_TOMCAT_SCRIPT_NAME" ] ; then
   	echo "$WSS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "$WSS_TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --yes "$WSS_TOMCAT_SCRIPT_NAME" "${WSS_TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
#
#
# =============================================================================
# The 52North WSS installation process
# =============================================================================
# 1 Download and Extract
# 2 tomcat set-up
# 2.0 check for webapps folder in $WSS_WAR_INSTALL_FOLDER
# 2.1 mv war to webapps folder
# 2.2 change owner of war file
#
#
# 1 Download 52nWSS and extract tar.gz
#
# create the TMP directory
mkdir -p "$TMP"
cd "$TMP"
#
# download tar.gz from 52north.org server
if [ -f "$WSS_TAR_NAME" ] ; then
   echo "$WSS_TAR_NAME has already been downloaded."
   # but was it sucessful?
else
   wget -c --no-check-certificate --progress=dot:mega \
	"$WSS_TAR_URL/$WSS_TAR_NAME"
fi

# extract tar, if folders are not there
tar xzf "$WSS_TAR_NAME"
#
# copy logo
mkdir -p /usr/local/share/icons
if [ ! -e "/usr/local/share/icons/$WSS_ICON_NAME" ] ; then
   mv "$WSS_ICON_NAME" /usr/local/share/icons/
fi

# 2.0 check for tomcat webapps folder
#
mkdir -p -v "$WSS_WAR_INSTALL_FOLDER"

#
#
# 2.1 + 2.2 check for tomcat set-up: look for service script in /etc/init.d/
#
if (test ! -d "$TOMCAT_WEBAPPS/$WSS_WEBAPP_CONTEXT") then
	mv "$TMP/$WSS_WAR_NAME.war" "$WSS_WAR_INSTALL_FOLDER"/
 	chown -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
	   "$WSS_WAR_INSTALL_FOLDER/$WSS_WAR_NAME.war"
else
	echo "$WSS_WAR_NAME --> $WSS_WEBAPP_CONTEXT already installed in tomcat"
fi

#
#
#
# Startup/Stop scripts set-up
# =============================================================================
mkdir -p "$WSS_BIN_FOLDER"
chgrp users "$WSS_BIN_FOLDER"

if [ ! -e $WSS_BIN_FOLDER/52nWSS-start.sh ] ; then
   cat << EOF > $WSS_BIN_FOLDER/52nWSS-start.sh
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" = "" ]; then
    sudo service tomcat7 start
    (sleep 2; echo "25"; sleep 2; echo "50"; sleep 2; echo "75"; sleep 2; echo "100") | zenity --progress --auto-close --text "52North WSS starting"
fi
firefox $WSS_URL $WSS_QUICKSTART_URL $WSS_OVERVIEW_URL
EOF
fi

if [ ! -e $WSS_BIN_FOLDER/52nWSS-stop.sh ] ; then
   cat << EOF > $WSS_BIN_FOLDER/52nWSS-stop.sh
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" != "" ]; then
    sudo service tomcat7 stop
    zenity --info --text "52North WSS stopped"
fi
EOF
fi

chmod 755 $WSS_BIN_FOLDER/52nWSS-start.sh
chmod 755 $WSS_BIN_FOLDER/52nWSS-stop.sh

#
#
#
# Desktop set-up
# =============================================================================

mkdir -p -v "$USER_HOME/Desktop"


# icon
# Relies on launchassist in home dir
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/$WSS_DESKTOP_STARTER_NAME ] ; then
   cat << EOF > /usr/local/share/applications/$WSS_DESKTOP_STARTER_NAME
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthWSS
Comment=52North WSS
Categories=Geospatial;Servers;
Exec=$WSS_BIN_FOLDER/52nWSS-start.sh
Icon=/usr/local/share/icons/$WSS_ICON_NAME
Terminal=false
EOF
fi

cp /usr/local/share/applications/$WSS_DESKTOP_STARTER_NAME "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/$WSS_DESKTOP_STARTER_NAME"

if [ ! -e /usr/local/share/applications/$WSS_DESKTOP_STOPER_NAME ] ; then
   cat << EOF > /usr/local/share/applications/$WSS_DESKTOP_STOPER_NAME
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop 52NorthWSS
Comment=52North WSS
Categories=Geospatial;Servers;
Exec=$WSS_BIN_FOLDER/52nWSS-stop.sh
Icon=/usr/local/share/icons/$WSS_ICON_NAME
Terminal=false
EOF
fi

cp /usr/local/share/applications/$WSS_DESKTOP_STOPER_NAME "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/$WSS_DESKTOP_STOPER_NAME"

#
# We just crossed the finish line
#
####
./diskspace_probe.sh "`basename $0`" end
