#!/bin/bash
#################################################################################
#
# Purpose: Installation of deegree-webservices-3.4.32 into Lubuntu
# Author:  Johannes Wilden <wilden@lat-lon.de>
# Credits: Stefan Hansen <shansen@lisasoft.com>
#          H.Bowman <hamish_b  yahoo com>
#          Judit Mays <mays@lat-lon.de>
#          Johannes Kuepper <kuepper@lat-lon.de>
#          Danilo Bretschneider <bretschneider@lat-lon.de>
#          Torsten Friebe <friebe@lat-lon.de>
#          Julian Zilz <zilz@lat-lon.de>
#          Brian M Hamlin  <maplabs@light42.com>
# Date:    $Date$
# Revision:$Revision$
#
#################################################################################
# Copyright (c) 2009-2022 lat/lon GmbH
# Copyright (c) 2016-2024 The Open Source Geospatial Foundation and others.
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
#################################################################################

# About:
# =====
# This script will install deegree-webservices
#
# deegree webservices version 3.6.0-pre2 runs with openjdk17 on Apache Tomcat 10.1.16
#

# Running:
# =======
# sudo ./install_deegree.sh

# =============================================================================
# Install script for deegree
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
START=$(date +%M:%S)
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_deegree"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat"
TOMCAT_SCRIPT_NAME="tomcat10"
DEEGREE_WEB_APP_NAME="deegree"
DEEGREE_VERSION="3.6.0-pre2"
DEEGREE_ICON_NAME="deegree_desktop_48x48.png"
DEEGREE_URL="http://localhost:8080/$DEEGREE_WEB_APP_NAME"
DEEGREE_WAR_INSTALL_FOLDER="/var/lib/$TOMCAT_SCRIPT_NAME/webapps"
DEEGREE_BIN_FOLDER="/usr/local/bin"
DEEGREE_WORKSPACE_ROOT="/var/lib/$TOMCAT_SCRIPT_NAME/.deegree"
TOMCAT_BIN_FOLDER="/usr/share/$TOMCAT_SCRIPT_NAME/bin"
TOMCAT_SERVICE_FOLDER="/etc/systemd/system/$TOMCAT_SCRIPT_NAME.service.d"

#
#
# =============================================================================
# Pre install checks
# =============================================================================
# 1 wget
# 2 java
#
#
# 1 wget
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again."
   exit 1
fi
# 2 java
if [ ! -x "`which java`" ] ; then
   echo "ERROR: java is required, please install it and try again."
   exit 1
fi

# =============================================================================
# The deegree installation process
# =============================================================================
# 1 Download and Extract
# 2 tomcat set-up
# 2.0 check for webapps folder in $DEEGREE_WAR_INSTALL_FOLDER
# 2.1 mv war to webapps folder
# 2.2 change owner of war file
#
#
# 1 Download deegree-webservices war and workspace
#
## create tmp folder
mkdir -p "$TMP"
cd "$TMP"

## download required stuff into tmp folder
wget -c --progress=dot:mega \
   -O "deegree-webservices-${DEEGREE_VERSION}.war" \
   "https://repo.deegree.org/repository/releases/org/deegree/deegree-webservices/${DEEGREE_VERSION}/deegree-webservices-${DEEGREE_VERSION}.war"
wget -c --progress=dot:mega \
   "https://repo.deegree.org/repository/releases/org/deegree/workspace/deegree-workspace-utah-light/20220701/deegree-workspace-utah-light-20220701.zip"

### install desktop icons ##
if [ ! -e "/usr/share/icons/$DEEGREE_ICON_NAME" ] ; then
   wget -nv "http://download.deegree.org/LiveDVD/FOSS4G2012/$DEEGREE_ICON_NAME"
   mv $DEEGREE_ICON_NAME /usr/share/icons/
fi

#
# 2 tomcat set-up
#
# we need to stop tomcat around this process
# NOTE: systemctl start/stop/status does not work in chroot, tomcat needs to be started mannually if needed.
TOMCAT=`systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l`
if [ $TOMCAT -eq 1 ]; then
    systemctl stop $TOMCAT_SCRIPT_NAME
    echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME stopped"
else
    echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME already stopped"
fi

#
# 2.0 check for tomcat webapps folder
#
if [ ! -d "$DEEGREE_WAR_INSTALL_FOLDER" ] ; then
    mkdir -p -v "$DEEGREE_WAR_INSTALL_FOLDER"
fi

#
# 2.1 mv war to webapps folder
#
if [ -d "$DEEGREE_WAR_INSTALL_FOLDER/$DEEGREE_WEB_APP_NAME" ] ; then
    echo "[$(date +%M:%S)]: $DEEGREE_WEB_APP_NAME $DEEGREE_VERSION already installed in tomcat. Removing..."
    rm -rv "$DEEGREE_WAR_INSTALL_FOLDER/$DEEGREE_WEB_APP_NAME"
fi
mv -v "$TMP/deegree-webservices-$DEEGREE_VERSION.war" "$DEEGREE_WAR_INSTALL_FOLDER/$DEEGREE_WEB_APP_NAME.war"
#
# 2.2 change owner of war file
#
chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME \
    "$DEEGREE_WAR_INSTALL_FOLDER/$DEEGREE_WEB_APP_NAME.war"
echo "[$(date +%M:%S)]: $DEEGREE_WEB_APP_NAME $DEEGREE_VERSION installed in tomcat webapps folder"
#
#
#
# Startup/Stop scripts set-up
# =============================================================================
if [ ! -e $DEEGREE_BIN_FOLDER/deegree_start.sh ] ; then
    cat << EOF > $DEEGREE_BIN_FOLDER/deegree_start.sh
#!/bin/bash
(sleep 1; echo "20"; sleep 1; echo "40"; sleep 1; echo "60"; sleep 1; echo "80"; sleep 1; echo "100") | zenity --progress --auto-close --text "deegree starting"&
TOMCAT=\`sudo systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l\`
if [ \$TOMCAT -ne 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME start
fi
sleep 5
sudo -u $USER_NAME firefox -new-tab $DEEGREE_URL
EOF
fi
#
if [ ! -e $DEEGREE_BIN_FOLDER/deegree_stop.sh ] ; then
   cat << EOF > $DEEGREE_BIN_FOLDER/deegree_stop.sh
#!/bin/bash
TOMCAT=\`sudo systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l\`
if [ \$TOMCAT -eq 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME stop
fi
zenity --info --text "deegree stopped"
EOF
fi
#
chmod 755 $DEEGREE_BIN_FOLDER/deegree_start.sh
chmod 755 $DEEGREE_BIN_FOLDER/deegree_stop.sh
#
#
# Desktop set-up
# =============================================================================
mkdir -p -v "$USER_HOME/Desktop"

## start icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-start.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start deegree
Comment=deegree webservices $DEEGREE_VERSION
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/bin/launchassist.sh $DEEGREE_BIN_FOLDER/deegree_start.sh
Icon=/usr/share/icons/$DEEGREE_ICON_NAME
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-start.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/deegree-start.desktop"

## stop icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop deegree
Comment=deegree webservices $DEEGREE_VERSION
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/bin/launchassist.sh  $DEEGREE_BIN_FOLDER/deegree_stop.sh
Icon=/usr/share/icons/$DEEGREE_ICON_NAME
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-stop.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/deegree-stop.desktop"
#
#
# Workspace set-up
# =============================================================================
## create DEEGREE_WORKSPACE_ROOT
rm -Rf "$DEEGREE_WORKSPACE_ROOT"
mkdir -p "$DEEGREE_WORKSPACE_ROOT"

## Extract utah workspace in DEEGREE_WORKSPACE_ROOT
cd "$DEEGREE_WORKSPACE_ROOT"
mkdir deegree-workspace-utah-light
cd deegree-workspace-utah-light
unzip -q "$TMP"/deegree-workspace-utah-light-20220701.zip

## Fix permissions
chown -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME "$DEEGREE_WORKSPACE_ROOT"

## Set CATALINA_OPTS for $DEEGREE_WORKSPACE_ROOT
if [ ! -e "$TOMCAT_BIN_FOLDER/setenv.sh" ] ; then
    cat << EOF > "$TOMCAT_BIN_FOLDER/setenv.sh"
#!/bin/sh

export CATALINA_OPTS="-DDEEGREE_WORKSPACE_ROOT=$DEEGREE_WORKSPACE_ROOT"
EOF
    chmod 755 "$TOMCAT_BIN_FOLDER/setenv.sh"
    chown root:$TOMCAT_USER_NAME "$TOMCAT_BIN_FOLDER/setenv.sh"
fi

if [ ! -d "$TOMCAT_SERVICE_FOLDER" ] ; then
    mkdir -p -v $TOMCAT_SERVICE_FOLDER
fi
if [ ! -e "$TOMCAT_SERVICE_FOLDER/override.conf" ] ; then
    cat << EOF > "$TOMCAT_SERVICE_FOLDER/override.conf"
[Service]
ReadWritePaths=/var/lib/$TOMCAT_SCRIPT_NAME/.deegree/
EOF
fi
# sudo systemctl daemon-reload

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
echo -e "Timing:\nStart: $START\nEnd  : $(date +%M:%S)"
