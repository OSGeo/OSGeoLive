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
# Version: 2014-07-30
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
START=$(date +%M:%S)
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_52nSOS"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat7"
TOMCAT_SCRIPT_NAME="$TOMCAT_USER_NAME"
SOS_WEB_APP_NAME="52nSOS"
SOS_ICON_NAME="52nSOS.png"
SOS_URL="http://localhost:8080/$SOS_WEB_APP_NAME"
SOS_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/52nSOS_quickstart.html"
SOS_OVERVIEW_URL="http://localhost/osgeolive/en/overview/52nSOS_overview.html"
SOS_WAR_INSTALL_FOLDER="/var/lib/$TOMCAT_SCRIPT_NAME/webapps"
SOS_INSTALL_FOLDER="/usr/local/52nSOS"
SOS_BIN_FOLDER="/usr/local/share/52nSOS"
SOS_TAR_NAME="52n-sos-osgeo-live-9.0.tar.gz"
SOS_TAR_URL="http://52north.org/files/sensorweb/osgeo-live/"
SOS_VERSION="4.3.0"
PG_OPTIONS='--client-min-messages=warning'
PG_USER="postgres"
PG_SCRIPT_NAME="postgresql"
PG_DB_NAME="52nSOS"
# -----------------------------------------------------------------------------
#
echo "[$START]: $SOS_WEB_APP_NAME $SOS_VERSION install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "TOMCAT_SCRIPT_NAME: $TOMCAT_SCRIPT_NAME"
echo "SOS_WAR_INSTALL_FOLDER: $SOS_WAR_INSTALL_FOLDER"
echo "SOS_INSTALL_FOLDER: $SOS_INSTALL_FOLDER"
echo "SOS_TAR_NAME: $SOS_TAR_NAME"
echo "SOS_TAR_URL: $SOS_TAR_URL"
echo "SOS_WEB_APP_NAME: $SOS_WEB_APP_NAME"
echo "SOS_ICON_NAME: $SOS_ICON_NAME"
echo "SOS_URL: $SOS_URL"
echo "SOS_QUICKSTART_URL: $SOS_QUICKSTART_URL"
echo "SOS_OVERVIEW_URL: $SOS_OVERVIEW_URL"
echo "SOS_VERSION: $SOS_VERSION"
echo "PG_OPTIONS: $PG_OPTIONS"
echo "PG_USER: $PG_USER"
echo "PG_SCRIPT_NAME: $PG_SCRIPT_NAME" 
echo "PG_DB_NAME: $PG_DB_NAME"
#
#
# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
# 3 tomcat
# 4 postgresql
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
# 3 tomcat
#
if [ -f "/etc/init.d/$TOMCAT_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --assume-yes "$TOMCAT_SCRIPT_NAME" "${TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
# 4 postgresql
#
if [ -f "/etc/init.d/$PG_SCRIPT_NAME" ] ; then
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$PG_SCRIPT_NAME"
fi
#
#
#
# =============================================================================
# The 52North SOS installation process
# =============================================================================
# 1 Download and Extract
# 2 Database set-up
# 2.1 create db with postgis extension
# 2.2 insert structure and data
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
# 2 Database set-up
#
# we need to stop tomcat around this process
TOMCAT=`service $TOMCAT_SCRIPT_NAME status | grep pid | wc -l`
if [ $TOMCAT -eq 1 ]; then
    service $TOMCAT_SCRIPT_NAME stop
fi
#
# we need a running postgresql server
POSTGRES=`service $PG_SCRIPT_NAME status | grep online | wc -l`
if [ $POSTGRES -ne 1 ]; then
    service $PG_SCRIPT_NAME start
fi
#	Check for database installation
#
SOS_DB_EXISTS="`su $PG_USER -c 'psql -l' | grep $PG_DB_NAME | wc -l`"
if [ $SOS_DB_EXISTS -gt 0 ] ; then
	echo "[$(date +%M:%S)]: SOS db $PG_DB_NAME exists -> drop it"
	su $PG_USER -c "dropdb $PG_DB_NAME"
fi
#
echo "[$(date +%M:%S)]: Create SOS db"
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' createdb --owner=$USER_NAME $PG_DB_NAME"
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql $PG_DB_NAME -c 'create extension postgis;'"
# su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql $PG_DB_NAME -c 'create extension postgis_topology;'"
echo "[$(date +%M:%S)]: DB $PG_DB_NAME created"
#
#   set-up SOS structure and data
#
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql -d $PG_DB_NAME -q -f $TMP/52nSOS.sql"
echo "[$(date +%M:%S)]: $PG_DB_NAME -> SOS database filled"
#
# final tidy up
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql -d $PG_DB_NAME -q -c 'VACUUM ANALYZE'"
#
# 3.0 check for tomcat webapps folder
#
mkdir -p -v "$SOS_WAR_INSTALL_FOLDER"
#
#
# 3.1 check for webapp set-up
#
if (test ! -d "$SOS_WAR_INSTALL_FOLDER/$SOS_WEB_APP_NAME") then
	mv -v "$TMP/$SOS_WEB_APP_NAME##$SOS_VERSION.war" "$SOS_WAR_INSTALL_FOLDER"/
 	chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
	   "$SOS_WAR_INSTALL_FOLDER/$SOS_WEB_APP_NAME##$SOS_VERSION.war"
	echo "[$(date +%M:%S)]: $SOS_WEB_APP_NAME $SOS_VERSION installed in tomcat webapps folder"
else
	echo "[$(date +%M:%S)]: $SOS_WEB_APP_NAME $SOS_VERSION already installed in tomcat"
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
(sleep 5; echo "25"; sleep 5; echo "50"; sleep 5; echo "75"; sleep 5; echo "100") | zenity --progress --auto-close --text "52North SOS starting"&
POSTGRES=\`sudo service $PG_SCRIPT_NAME status | grep online | wc -l\`
if [ \$POSTGRES -ne 1 ]; then
    sudo service $PG_SCRIPT_NAME start
fi
TOMCAT=\`sudo service $TOMCAT_SCRIPT_NAME status | grep pid | wc -l\`
if [ \$TOMCAT -ne 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME start
fi
firefox $SOS_URL $SOS_QUICKSTART_URL $SOS_OVERVIEW_URL
EOF
fi
#
if [ ! -e $SOS_BIN_FOLDER/52nSOS-stop.sh ] ; then
   cat << EOF > $SOS_BIN_FOLDER/52nSOS-stop.sh
#!/bin/bash
TOMCAT=\`sudo service $TOMCAT_SCRIPT_NAME status | grep pid | wc -l\`
if [ \$TOMCAT -eq 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME stop
fi
zenity --info --text "52North SOS stopped"
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
echo -e "Timing:\nStart: $START\nEnd  : $(date +%M:%S)"
