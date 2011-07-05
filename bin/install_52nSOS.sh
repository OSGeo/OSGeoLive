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
# Version: 2011-01-28
# Author: e.h.juerrens@52north.org
# TODO
# - more log output during install
# - add different data sets (small, medium, large) using a parameter beginning
#	this script
# - maybe delete war file after set-up in tomcat (?) -> save space on disc
#
# About:
# =====
# This script will install 52nSOS
#
#
# =============================================================================
# Install script for 52nSOS
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
TMP="/tmp/build_52nSOS"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat6"
SOS_WAR_INSTALL_FOLDER="/var/lib/tomcat6/webapps"
SOS_INSTALL_FOLDER="/usr/local/52nSOS"
SOS_TAR_NAME="52n-sensorweb-sos-osgeolive.tar.gz"
SOS_TAR_URL="http://52north.org/files/sensorweb/osgeo-live/"
# when changing this, adjust the name in line 215, too,
# and the quickstart, which links to this, too
SOS_WEB_APP_NAME="52nSOS"
SOS_POSTGRESQL_SCRIPT_NAME="postgresql-8.4"
SOS_TOMCAT_SCRIPT_NAME="tomcat6"
SOS_ICON_NAME="52nSOS.png"
SOS_DATA_SET="DATA.sql"
SOS_URL="http://localhost:8080/$SOS_WEB_APP_NAME"
SOS_QUICKSTART_URL="http://localhost/en/quickstart/52nSOS_quickstart.html"
SOS_OVERVIEW_URL="http://localhost/en/overview/52nSOS_overview.html"
# -----------------------------------------------------------------------------
#
echo "52nSOS install started"
if [ -n "$DEBUG" ] ; then
   echo "$TMP"
   echo "$USER_NAME"
   echo "$USER_HOME"
   echo "$TOMCAT_USER_NAME"
   echo "$SOS_WAR_INSTALL_FOLDER"
   echo "$SOS_INSTALL_FOLDER"
   echo "$SOS_TAR_NAME"
   echo "$SOS_TAR_URL"
   echo "$SOS_WEB_APP_NAME"
   echo "$SOS_POSTGRESQL_SCRIPT_NAME"
   echo "$SOS_TOMCAT_SCRIPT_NAME"
   echo "$SOS_ICON_NAME"
   echo "$SOS_DATA_SET"
   echo "$SOS_URL"
   echo "$SOS_QUICKSTART_URL"
   echo "$SOS_OVERVIEW_URL"
fi

#
# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
# 3 postgresql
# 4 tomcat6
#
#
#
# 1 WGET
# It is required to download the 52North SOS package:
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
	apt-get update
	#
	apt-get --assume-yes remove openjdk-6-jre
	apt-get --assume-yes install java-common sun-java6-bin sun-java6-jre sun-java6-jdk
	# this should probably be taken care of system-wide in /etc/rc.local if not already:
	echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun" >> ~/.bashrc
fi
#
#
#
# 3 postgresql
if [ -f "/etc/init.d/$SOS_POSTGRESQL_SCRIPT_NAME" ] ; then
   	echo "$SOS_POSTGRESQL_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "$SOS_POSTGRESQL_SCRIPT_NAME not found. Installing it..."
	apt-get install --yes "$SOS_POSTGRESQL_SCRIPT_NAME"
fi
#
#
#
# 4 tomcat6
if [ -f "/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" ] ; then
   	echo "$SOS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "$SOS_TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --yes "$SOS_TOMCAT_SCRIPT_NAME" "${SOS_TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
#
#
# =============================================================================
# The 52North SOS installation process
# =============================================================================
# 1 Download and Extract
# 2 Database set-up:
# 2.1 set-up SOS database using sql scripts
# 2.2 insert data
# 3 tomcat set-up
# 3.0 check for webapps folder in $SOS_WAR_INSTALL_FOLDER
# 3.1 mv war to webapps folder
# 3.2 change owner of war file
#
#
# 1 Download 52nSOS and extract tar.gz
#
# create the TMP directory
mkdir -p "$TMP"
cd "$TMP"
#
# download tar.gz from 52north.org server
if [ -f "$SOS_TAR_NAME" ] ; then
   echo "$SOS_TAR_NAME has already been downloaded."
   # but was is sucessful?
else
   wget -c --progress=dot:mega "$SOS_TAR_URL$SOS_TAR_NAME"
fi

# extract tar, if folders are not there
tar xzf "$SOS_TAR_NAME"
#
# copy logo
if [ ! -e "/usr/share/icons/$SOS_ICON_NAME" ] ; then
   mv "$SOS_ICON_NAME" /usr/share/icons/
fi

# 	# copy start script
#	if [ ! -e "$SOS_INSTALL_FOLDER/$SOS_START_SCRIPT" ] ; then
#		mkdir -p "$SOS_INSTALL_FOLDER"
# 		mv "$SOS_START_SCRIPT" "$SOS_INSTALL_FOLDER"
# 		chown -R $USER_NAME:$USER_NAME "$SOS_INSTALL_FOLDER/$SOS_START_SCRIPT"
# 		chmod u+x,g+x,o+x "$SOS_INSTALL_FOLDER/$SOS_START_SCRIPT"
#	fi
#
#
#
# 2 database set-up
#
# we need to stop tomcat6 around this process
"/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" stop
if [ -n "$DEBUG" ] ; then
	echo "installing SOS datastructe structure in Postgresql DB..."
fi
su postgres -c "psql -q -f $TMP/SOS-structure.sql &> /dev/null"
if [ -n "$DEBUG" ] ; then
	echo "done."
	echo "installing structure in SOS (offerings, procedures,...) ... "
fi
su postgres -c "psql -q -f $TMP/STRUCTURE-in-SOS.sql &> /dev/null"
if [ -n "$DEBUG" ] ; then
	echo "done."
	echo "installing observations in SOS using $SOS_DATA_SET.sql"
fi
su postgres -c "psql -q -f $TMP/$SOS_DATA_SET.sql &> /dev/null"
if [ -n "$DEBUG" ] ; then
	echo "done."
fi
"/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" start
#
#
# 3.0 check for tomcat webapps folder
#
mkdir -p -v "$SOS_WAR_INSTALL_FOLDER"
if [ -n "$DEBUG" ] ; then
	echo "install dir created/found."
fi
#
#
# 3.1 check for tomcat set-up: look for service script in /etc/init.d/
#
if (test ! -d "$TOMCAT_WEBAPPS/$SOS_WEB_APP_NAME") then
	mv "$TMP/$SOS_WEB_APP_NAME.war" "$SOS_WAR_INSTALL_FOLDER"/
 	chown -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
	   "$SOS_WAR_INSTALL_FOLDER/$SOS_WEB_APP_NAME.war"
	if [ -n "$DEBUG" ] ; then
		echo "52nSOS deployed via mv to webapps dir."
	fi
else
	echo "$SOS_WEB_APP_NAME already installed in tomcat"
fi
#
#
#
# Desktop set-up
# =============================================================================

mkdir -p -v "$USER_HOME/Desktop"

# icon
# Relies on launchassist in home dir
if [ ! -e /usr/share/applications/52nSOS-start.desktop ] ; then
   cat << EOF > /usr/share/applications/52nSOS-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start 52NorthSOS
Comment=52North SOS
Categories=Geospatial;Servers;
Exec=firefox $SOS_URL $SOS_QUICKSTART_URL $SOS_OVERVIEW_URL
Icon=/usr/share/icons/$SOS_ICON_NAME
Terminal=false
EOF
fi

cp /usr/share/applications/52nSOS-start.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-start.desktop"
#
# We just crossed the finish line
#
echo "                                                                         "
echo "                         52nSOS install finished                         "
echo "#########################################################################"
echo "                                                                         "
echo "                                                                         "
