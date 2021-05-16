#!/bin/sh
# Copyright (c) 2013-2021 The Open Source Geospatial Foundation and others.
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

TOMCAT_NAME="tomcat9"
TOMCAT_USER_NAME="tomcat"
TOMCAT_USER_HOME="/usr/share/${TOMCAT_NAME}"
WMS_WAR_INSTALL_DIR="/var/lib/${TOMCAT_NAME}/webapps"
WMS_BIN_DIR="/usr/local/share/ncWMS"
WMS_WAR_URL="https://github.com/Reading-eScience-Centre/ncwms/releases/download/ncwms-2.4.2/"
WMS_WAR_NAME="ncWMS2.war"
WMS_WEB_APP_NAME="ncWMS2"
WMS_TOMCAT_SCRIPT_NAME="$TOMCAT_NAME"
WMS_ICON_NAME="ncWMS_icon.png"
WMS_URL="http://localhost:8080/$WMS_WEB_APP_NAME"
WMS_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/ncWMS_quickstart.html"
WMS_OVERVIEW_URL="http://localhost/osgeolive/en/overview/ncWMS_overview.html"

echo "[$(date +%M:%S)]: ncWMS2 install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "WMS_WAR_INSTALL_DIR: $WMS_WAR_INSTALL_DIR"
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
# 3 tomcat

# 1 WGET
# It is required to download the ncWMS package:

if [ ! -x "`which wget`" ] ; then
    apt-get install wget
fi

# 2 Check for OpenJDK

if [ ! -x "`which java`" ] ; then
    apt-get -q update
    #
    apt-get --assume-yes install default-jre
fi

# 3 tomcat
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

# Download tar.gz from sf.net server
if [ -f "$WMS_WAR_NAME" ] ; then
    echo "[$(date +%M:%S)]: $WMS_WAR_NAME has already been downloaded."
else
    if [ `ls "$TMP" | wc -l` -ne 0 ] ; then
	### danger: if $TMP gets commented out above it becomes empty, then guess what happens...
	rm -v -r "$TMP"/*
    fi
    wget -c --progress=dot:mega "$WMS_WAR_URL$WMS_WAR_NAME" -O "$TMP/$WMS_WAR_NAME"
fi

# Copy icon to the icons dir
mkdir -p /usr/local/share/icons
if [ ! -e "/usr/local/share/icons/$WMS_ICON_NAME" ] ; then
    cp -v "../app-conf/ncwms/$WMS_ICON_NAME" /usr/local/share/icons/
    chmod 644 "/usr/local/share/icons/$WMS_ICON_NAME"
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
mkdir -p -v "$TOMCAT_USER_HOME/.ncWMS2"

if [ ! -e "$TOMCAT_USER_HOME/.ncWMS2/config.xml" ] ; then
    cp -v ../app-conf/ncwms/config.xml "$TOMCAT_USER_HOME/.ncWMS2/config.xml"
    chmod 644 "$TOMCAT_USER_HOME/.ncWMS2/config.xml"
fi

chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME "$TOMCAT_USER_HOME/.ncWMS2"

# Create startup/shutdown scripts
mkdir -p "$WMS_BIN_DIR"
chgrp users "$WMS_BIN_DIR"

### sudo may need password when the , if so try "echo $pw | sudo -S ..."
### is bash really needed here? I don't see any bashisms. -> #!/bin/sh ?
if [ ! -e "$WMS_BIN_DIR/ncWMS-start.sh" ] ; then
    cat << EOF > "$WMS_BIN_DIR/ncWMS-start.sh"
    #!/bin/bash
    STAT=\`sudo service $WMS_TOMCAT_SCRIPT_NAME status | grep PID\`
    if [ -z "\$STAT" ] ; then
        sudo service $WMS_TOMCAT_SCRIPT_NAME start
        (sleep 5; echo "25"; sleep 5; echo "50"; sleep 5; echo "75"; sleep 5; echo "100") \
	   | zenity --progress --auto-close --text "ncWMS starting"
    fi
    firefox "$WMS_URL/Godiva3.html" "$WMS_QUICKSTART_URL" "$WMS_OVERVIEW_URL"
EOF
fi

### same sudo and bash comments as above
if [ ! -e "$WMS_BIN_DIR/ncWMS-stop.sh" ] ; then
    cat << EOF > "$WMS_BIN_DIR/ncWMS-stop.sh"
    #!/bin/bash
    STAT=\`sudo service $WMS_TOMCAT_SCRIPT_NAME status | grep PID\`
    if [ -n "\$STAT" ] ; then
        sudo service $WMS_TOMCAT_SCRIPT_NAME stop
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
Name=Start ncWMS2
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
Name=Stop ncWMS2
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

# NOTE (#2084): An extra step is added in setdown.sh to edit WEB-INF/web.xml after
# tomcat has been restarted and ncWMS has been deployed.

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
