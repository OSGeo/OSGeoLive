#!/bin/sh
# Copyright (c) 2013 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
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
# Version: 2013-06-07
# Author: guy.griffiths@reading.ac.uk adapted install_52nWPS.sh by:
#         e.h.juerrens@52north.org, b.pross@52north.org
#
# About:
# =====
# This script installs ncWMS

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
    USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_ncWMS"

TOMCAT_USER_NAME="tomcat7"
TOMCAT_USER_HOME="/usr/share/tomcat7"
WMS_WAR_INSTALL_DIR="/var/lib/tomcat7/webapps"
WMS_BIN_DIR="/usr/local/share/ncWMS"
WMS_TAR_NAME="ncWMS_osgeo.tar.gz"
WMS_TAR_URL="http://downloads.sourceforge.net/project/ncwms/ncwms/osgeo-1.2/"
WMS_WAR_NAME="ncWMS-1.2.war"
WMS_WEB_APP_NAME="ncWMS"
WMS_TOMCAT_SCRIPT_NAME="tomcat7"
WMS_ICON_NAME="ncWMS_icon.png"
WMS_URL="http://localhost:8080/$WMS_WEB_APP_NAME"
WMS_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/ncWMS_quickstart.html"
WMS_OVERVIEW_URL="http://localhost/osgeolive/en/overview/ncWMS_overview.html"

echo "[$(date +%M:%S)]: ncWMS install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "WMS_WAR_INSTALL_DIR: $WMS_WAR_INSTALL_DIR"
echo "WMS_TAR_NAME: $WMS_TAR_NAME"
echo "WMS_TAR_URL: $WMS_TAR_URL"
echo "WMS_WEB_APP_NAME: $WMS_WEB_APP_NAME"
echo "WMS_TOMCAT_SCRIPT_NAME: $WMS_TOMCAT_SCRIPT_NAME"
echo "WMS_ICON_NAME: $WMS_ICON_NAME"
echo "WMS_URL: $WMS_URL"
echo "WMS_QUICKSTART_URL: $WMS_QUICKSTART_URL"
echo "WMS_OVERVIEW_URL: $WMS_OVERVIEW_URL"

# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
# 3 tomcat7

# 1 WGET
# It is required to download the ncWMS package:

if [ ! -x "`which wget`" ] ; then
    apt-get install wget
fi

# 2 Check for OpenJDK

if [ ! -x "`which java`" ] ; then
    apt-get -q update
    #
    apt-get --assume-yes install openjdk-7-jre
fi

# 3 tomcat7
if [ -f "/etc/init.d/$WMS_TOMCAT_SCRIPT_NAME" ] ; then
    echo "[$(date +%M:%S)]: $WMS_TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $WMS_TOMCAT_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$WMS_TOMCAT_SCRIPT_NAME" "${WMS_TOMCAT_SCRIPT_NAME}-admin"
fi

# =============================================================================
# The ncWMS installation process
# =============================================================================

# Create the TMP directory
mkdir -p "$TMP"
cd "$TMP"

# Download tar.gz from sf.net server
if [ -f "$WMS_TAR_NAME" ] ; then
    echo "[$(date +%M:%S)]: $WMS_TAR_NAME has already been downloaded."
else
    if [ `ls "$TMP" | wc -l` -ne 0 ] ; then
	### danger: if $TMP gets commented out above it becomes empty, then guess what happens...
	rm -v -r "$TMP"/*
    fi
    wget -N --progress=dot:mega "$WMS_TAR_URL$WMS_TAR_NAME"
fi

# Extract .war file (+ config + icon) from tar.gz file
if [ -f "$WMS_WAR_NAME" ] ; then
    echo "[$(date +%M:%S)]: $WMS_WAR_NAME has already been extracted."
else
    tar xzf "$WMS_TAR_NAME" --no-same-owner
    echo "[$(date +%M:%S)]: $WMS_TAR_NAME extracted"
fi

# Copy icon to the icons dir
mkdir -p /usr/local/share/icons
if [ ! -e "/usr/local/share/icons/$WMS_ICON_NAME" ] ; then
    chmod 644 "$WMS_ICON_NAME"
    mv -v "$WMS_ICON_NAME" /usr/local/share/icons/
fi

# Check for tomcat webapps folder
mkdir -p -v "$WMS_WAR_INSTALL_DIR"

if (test ! -d "$WMS_WAR_INSTALL_DIR/$WMS_WEB_APP_NAME") then
    mv -v "$TMP/$WMS_WAR_NAME" "$WMS_WAR_INSTALL_DIR/$WMS_WEB_APP_NAME.war"
    chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
        "$WMS_WAR_INSTALL_DIR/$WMS_WEB_APP_NAME.war"
    echo "[$(date +%M:%S)]: $WMS_WEB_APP_NAME installed in tomcat webapps folder"
else
    echo "[$(date +%M:%S)]: $WMS_WEB_APP_NAME already installed in tomcat"
fi

# Copy the configuration file to the ncWMS config dir, creating it if necessary
###  ? does it really need to be hidden? makes it harder to maintain
mkdir -p -v "$TOMCAT_USER_HOME/.ncWMS"

if [ ! -e "$TOMCAT_USER_HOME/.ncWMS/config.xml" ] ; then
    chmod 644 ncWMS_config.xml
    mv -v ncWMS_config.xml "$TOMCAT_USER_HOME/.ncWMS/config.xml"
fi

chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME "$TOMCAT_USER_HOME/.ncWMS"

# Create startup/shutdown scripts
mkdir -p "$WMS_BIN_DIR"
chgrp users "$WMS_BIN_DIR"

### sudo may need password when the , if so try "echo $pw | sudo -S ..."
### is bash really needed here? I don't see any bashisms. -> #!/bin/sh ?
if [ ! -e "$WMS_BIN_DIR/ncWMS-start.sh" ] ; then
    cat << EOF > "$WMS_BIN_DIR/ncWMS-start.sh"
    #!/bin/bash
    STAT=\`sudo service tomcat7 status | grep pid\`
    if [ -z "\$STAT" ] ; then
        sudo service tomcat7 start
        (sleep 2; echo "25"; sleep 2; echo "50"; sleep 2; echo "75"; sleep 2; echo "100") \
	   | zenity --progress --auto-close --text "ncWMS starting"
    fi
    firefox "$WMS_URL/godiva2.html" "$WMS_QUICKSTART_URL" "$WMS_OVERVIEW_URL"
EOF
fi

### same sudo and bash comments as above
if [ ! -e "$WMS_BIN_DIR/ncWMS-stop.sh" ] ; then
    cat << EOF > "$WMS_BIN_DIR/ncWMS-stop.sh"
    #!/bin/bash
    STAT=\`sudo service tomcat7 status | grep pid\`
    if [ -n "\$STAT" ] ; then
        sudo service tomcat7 stop
        zenity --info --text "ncWMS stopped"
    fi
EOF
fi

chmod 755 "$WMS_BIN_DIR/ncWMS-start.sh"
chmod 755 "$WMS_BIN_DIR/ncWMS-stop.sh"


# Desktop set-up
mkdir -p -v "$USER_HOME/Desktop"

# Create the launch file
if [ ! -e /usr/local/share/applications/ncWMS-start.desktop ] ; then
    cat << EOF > /usr/local/share/applications/ncWMS-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start ncWMS
Comment=ncWMS - A WMS server for NetCDF files
Categories=Application;Geography;Geoscience;
Exec=$WMS_BIN_DIR/ncWMS-start.sh
Icon=/usr/local/share/icons/$WMS_ICON_NAME
Terminal=false
EOF
fi

cp -v /usr/local/share/applications/ncWMS-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/ncWMS-start.desktop"

# Create the launch file
if [ ! -e /usr/local/share/applications/ncWMS-stop.desktop ] ; then
    cat << EOF > /usr/local/share/applications/ncWMS-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop ncWMS
Comment=ncWMS - A WMS server for NetCDF files
Categories=Application;Geography;Geoscience;
Exec=$WMS_BIN_DIR/ncWMS-stop.sh
Icon=/usr/local/share/icons/$WMS_ICON_NAME
Terminal=false
EOF
fi

cp -v /usr/local/share/applications/ncWMS-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/ncWMS-stop.desktop"

# All done

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
