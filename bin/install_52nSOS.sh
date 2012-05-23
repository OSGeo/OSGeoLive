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
# Version: 2011-07-05
# Author: e.h.juerrens@52north.org
# TODO
# - add different data sets (small, medium, large) using a parameter beginning
#	this script
# - maybe delete war file after set-up in tomcat (?) -> save space on disc
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
TMP="/tmp/build_52nSOS"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat6"
SOS_WAR_INSTALL_FOLDER="/var/lib/tomcat6/webapps"
SOS_INSTALL_FOLDER="/usr/local/52nSOS"
SOS_TAR_NAME="52n-sensorweb-sos-osgeolive-6.0.0.tar.gz"
SOS_TAR_URL="http://52north.org/files/sensorweb/osgeo-live/"
# when changing this, adjust the name in line 215, too,
# and the quickstart, which links to this, too
SOS_WEB_APP_NAME="52nSOS"
SOS_POSTGRESQL_SCRIPT_NAME="postgresql"
PGOPTIONS='--client-min-messages=warning'
SOS_DB_NAME="52nSOS"
SOS_TOMCAT_SCRIPT_NAME="tomcat6"
SOS_ICON_NAME="52nSOS.png"
SOS_DATA_SET="DATA"
SOS_URL="http://localhost:8080/$SOS_WEB_APP_NAME"
SOS_QUICKSTART_URL="http://localhost/en/quickstart/52nSOS_quickstart.html"
SOS_OVERVIEW_URL="http://localhost/en/overview/52nSOS_overview.html"
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
echo "SOS_POSTGRESQL_SCRIPT_NAME: $SOS_POSTGRESQL_SCRIPT_NAME"
echo "PGOPTIONS: $PGOPTIONS"
echo "SOS_DB_NAME: $SOS_DB_NAME"
echo "SOS_TOMCAT_SCRIPT_NAME: $SOS_TOMCAT_SCRIPT_NAME"
echo "SOS_ICON_NAME: $SOS_ICON_NAME"
echo "SOS_DATA_SET: $SOS_DATA_SET"
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
# 2 Check for OpenJDK
#
if [ ! -x "`which java`" ] ; then
	apt-get update
	#
	apt-get --assume-yes install openjdk-6-jre
fi
#
#
#
# 3 postgresql
if [ -f "/etc/init.d/$SOS_POSTGRESQL_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $SOS_POSTGRESQL_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "[$(date +%M:%S)]: $SOS_POSTGRESQL_SCRIPT_NAME not found. Installing it..."
	apt-get install --assume-yes "$SOS_POSTGRESQL_SCRIPT_NAME"
fi
#
#
#
# 4 tomcat6
if [ -f "/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $SOS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
	echo "[$(date +%M:%S)]: $SOS_TOMCAT_SCRIPT_NAME not found. Installing it..."
	apt-get install --assume-yes "$SOS_TOMCAT_SCRIPT_NAME" "${SOS_TOMCAT_SCRIPT_NAME}-admin"
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
   echo "[$(date +%M:%S)]: $SOS_TAR_NAME has already been downloaded."
   # but was it sucessful?
else
#
#	TODO is this new command working?
#
	rm -v -r "$TMP"/*
   	wget -c --progress=dot:mega "$SOS_TAR_URL$SOS_TAR_NAME"
fi
#
# extract tar, if folders are not there
tar xzf "$SOS_TAR_NAME"
echo "[$(date +%M:%S)]: $SOS_TAR_NAME extracted"
#
# copy logo
if [ ! -e "/usr/share/icons/$SOS_ICON_NAME" ] ; then
   mv -v "$SOS_ICON_NAME" /usr/share/icons/
fi
#
#
# 2 database set-up
#
# we need to stop tomcat6 around this process
"/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" stop
echo "[$(date +%M:%S)]: installing SOS datastructe structure in Postgresql DB..."
#fi
#
#	Check postgis_template installation
#
POSTGIS="`su postgres -c 'psql -l' | grep template_postgis | wc -l`"
if [ $POSTGIS -gt 0 ] ; then
	echo "[$(date +%M:%S)]: database template_postgis already installed"
else 
	echo "[$(date +%M:%S)]: Installing template_postgis"
	su postgres -c 'createdb -E UTF8 -U postgres template_postgis'
	su postgres -c 'createlang -d template_postgis plpgsql;'
	su postgres -c 'psql -U postgres -d template_postgis -c"CREATE EXTENSION hstore;"'
	su postgres -c 'psql -U postgres -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql'
	su postgres -c 'psql -U postgres -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql'
	su postgres -c 'psql -U postgres -d template_postgis -c"select postgis_lib_version();"'
	su postgres -c 'psql -U postgres -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"'
	su postgres -c 'psql -U postgres -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"'
	su postgres -c 'psql -U postgres -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"'
	echo "[$(date +%M:%S)]: finished postgis_template set-up"
fi
#
#	Check for database installation
#
SOS_DB_EXISTS="`su postgres -c 'psql -l' | grep $SOS_DB_NAME | wc -l`"
if [ $SOS_DB_EXISTS -gt 0 ] ; then
	echo "[$(date +%M:%S)]: SOS db $SOS_DB_NAME exists -> drop it"
	su postgres -c "dropdb $SOS_DB_NAME"
fi
echo "[$(date +%M:%S)]: Create SOS db"
su postgres -c "createdb -T template_postgis $SOS_DB_NAME"
echo "[$(date +%M:%S)]: DB $SOS_DB_NAME created"
#
#	Set-Up 52nSOS database model

su postgres -c "PGOPTIONS='$PGOPTIONS' psql -d $SOS_DB_NAME -q -f $TMP/SOS-structure.sql"
echo "[$(date +%M:%S)]: $SOS_DB_NAME -> SOS database model created"
#
#	Set-Up Example data model 
#
su postgres -c "psql -d $SOS_DB_NAME -q -f $TMP/STRUCTURE-in-SOS.sql"
echo "[$(date +%M:%S)]: $SOS_DB_NAME -> Example data model created"
#
#	Insert example observations
#
su postgres -c "psql -d $SOS_DB_NAME -q -f $TMP/$SOS_DATA_SET.sql"
echo "[$(date +%M:%S)]: $SOS_DB_NAME -> Example observations inserted"
echo "[$(date +%M:%S)]: Database set-up finished"
#
#	Change password of postgres to "user" while user "user" is not present
#
su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'user';\""
echo "[$(date +%M:%S)]: password for user Postgres changed to user"
#
#	Restart tomcat after database set-up
#
"/etc/init.d/$SOS_TOMCAT_SCRIPT_NAME" start
#
#
# 3.0 check for tomcat webapps folder
#
mkdir -p -v "$SOS_WAR_INSTALL_FOLDER"
#
#
# 3.1 check for tomcat set-up: look for service script in /etc/init.d/
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
#
cp -v /usr/share/applications/52nSOS-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/52nSOS-start.desktop"
#
# We just crossed the finish line
#
echo "[$(date +%M:%S)]                                                         "
echo "                         52nSOS install finished                         "
echo "#########################################################################"

