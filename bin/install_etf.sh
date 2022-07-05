#!/bin/sh
#############################################################################
#
# Purpose: This script will install INSPIRE ETF
# Author:
# Version 2020-08-28
#
#############################################################################
# Copyright (c) 2011-2019 The Open Source Geospatial Foundation and others.
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
#############################################################################
from cloudinit.util import chmod

# =============================================================================
# Install script for ETF
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
START=$(date +%M:%S)
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
TMP="/tmp/build_etf"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
JETTY9_SCRIPT_NAME="jetty9"
ETF_WEB_APP_NAME="ETF"
ETF_ICON_NAME="ETF_logo.png" #to be changed to the INSPIRE logo
ETF_URL="http://localhost:9090/ETF"
ETF_PORT="9090"
ETF_FOLDER="$USER_HOME/.etf"
ETF_WAR_INSTALL_FOLDER="/usr/share/$JETTY9_SCRIPT_NAME/webapps"
ETF_BIN_FOLDER="/usr/local/share/ETF"
ETF_VERSION="2.0"
JAVA_PKG="openjdk-8-jdk-headless"
JETTY9_HOME="/usr/share/$JETTY9_SCRIPT_NAME"

# -----------------------------------------------------------------------------
#
echo "[$START]: $ETF_WEB_APP_NAME $ETF_VERSION install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "JETTY9_SCRIPT_NAME: $JETTY9_SCRIPT_NAME"
echo "JETTY9_HOME: $JETTY9_HOME"
echo "ETF_FOLDER: $ETF_FOLDER"
echo "ETF_WAR_INSTALL_FOLDER: $ETF_WAR_INSTALL_FOLDER"
echo "ETF_WEB_APP_NAME: $ETF_WEB_APP_NAME"
echo "ETF_ICON_NAME: $ETF_ICON_NAME"
echo "ETF_PORT: $ETF_PORT"
echo "ETF_URL: $ETF_URL"
echo "ETF_VERSION: $ETF_VERSION"
echo "JAVA_PKG: $JAVA_PKG"
#
#
# =============================================================================
# Pre install checks
# =============================================================================

# 1 java
# 2 JETTY9

#
#
#
# 1 Check for OpenJDK
#
if [ ! -x "`which java`" ] ; then
    apt-get -q update
    apt-get --assume-yes install $JAVA_PKG
fi
#
#
# 2 JETTY9
#
if [ -f "/etc/init.d/$JETTY9_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $JETTY9_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $JETTY9_SCRIPT_NAME not found. Installing it..."
    sudo apt-get install --assume-yes "$JETTY9_SCRIPT_NAME"
    sudo sed -i 's/\(#JETTY_USER=\).*/\1''/' /etc/default/jetty9
fi


# =============================================================================
# The INSPIRE ETF installation process
# =============================================================================
# 1 Download ETF.war and ETS
# 3 JETTY9 set-up
# 4 move ETF.war to $ETF_WAR_INSTALL_FOLDER
# 5.1 start ETF 
# 5.1 stop ETF
# 5.1 move ETS to $ETF_FOLDER/projects/inspire-ets-repository/
# 6 make modifiable webapps folder
#
#
# 1 Download ETF
#
# create the TMP directory and download the ETF git repository
mkdir -p "$TMP"
cd "$TMP"
wget -c --no-check-certificate https://github.com/etf-validator/OSGeoLive-ETF/releases/download/OSGeoLive15.0-alpha/ETF.war
wget -c --no-check-certificate https://github.com/etf-validator/OSGeoLive-ETF/releases/download/OSGeoLive15.0-alpha/ets-repository-2022.1.zip

#
# copy logo
sudo mkdir -p /usr/local/share/icons
if [ ! -e "/usr/local/share/icons/$ETF_ICON_NAME" ] ; then
sudo mv -v "$USER_HOME/gisvm/app-conf/ETF/$ETF_ICON_NAME" /usr/local/share/icons/
sudo chmod 777 "/usr/local/share/icons/$ETF_ICON_NAME"
fi
#
#
# 2 Database set-up
#
# we need to stop JETTY9 around this process
JETTY9=`systemctl status $JETTY9_SCRIPT_NAME | grep "Active: active" | wc -l`
if [ $JETTY9 -eq 1 ]; then
    sudo systemctl stop $JETTY9_SCRIPT_NAME
    echo "[$(date +%M:%S)]: $JETTY9_SCRIPT_NAME stopped"
else
    echo "[$(date +%M:%S)]: $JETTY9_SCRIPT_NAME already stopped"
fi


#
# Change java version, move the war and move to the servlet container folder
#


sudo cp "$TMP/ETF.war" "$ETF_WAR_INSTALL_FOLDER"/ 
#
# It puts the ETS repository to its place
#
sudo sed -i "s/jetty.http.port=8080/jetty.http.port=$ETF_PORT/g" "$JETTY9_HOME/start.ini"
/usr/share/jetty9/bin/jetty.sh start
wait
/usr/share/jetty9/bin/jetty.sh stop
if [ ! -d "$ETF_FOLDER/projects/inspire-ets-repository/ets-repository-2022.1" ];then
	sudo mkdir "$ETF_FOLDER/projects/inspire-ets-repository/"
	cd "$ETF_FOLDER/projects/inspire-ets-repository/"
	sudo unzip -o "$TMP/ets-repository-2022.1.zip"
fi
#
# It makes modifiable the folder containing jetty for it to work perfectly
#
sudo chmod a+rw "$JETTY9_HOME"
sudo chmod 777 "$JETTY9_HOME/start.ini"
#
echo "[$(date +%M:%S)]: $ETF_WEB_APP_NAME $ETF_VERSION installed in JETTY9 webapps folder"
#
#
#
# Startup/Stop scripts set-up
# =============================================================================
sudo mkdir -p "$ETF_BIN_FOLDER"
sudo chmod 777 "$ETF_BIN_FOLDER/"

if [ ! -e $ETF_BIN_FOLDER/etf-start.sh ] ; then
    cat << EOF > $ETF_BIN_FOLDER/etf-start.sh
#!/bin/bash
SERVICEJETTY=\`systemctl status jetty9 | grep "Active: active" | wc -l\`
if [ \$SERVICEJETTY -eq 1 ]; then
	systemctl stop jetty9
fi
sed -i "s/jetty.port=8080/jetty.port=$ETF_PORT/g" "$JETTY9_HOME/start.ini"
sed -i "s/jetty.http.port=8080/jetty.http.port=$ETF_PORT/g" "$JETTY9_HOME/start.ini"
DELAY=90
JETTY9=\`/usr/share/jetty9/bin/jetty.sh status | grep "Jetty running pid=" | wc -l\`
if [ \$JETTY9 -ne 1 ]; then
	/usr/share/jetty9/bin/jetty.sh start &
	( 
	for TIME in \`seq \$DELAY\`; do
		sleep 1
		echo "\$TIME \$DELAY" | awk '{print int(0.5+100*\$1/\$2)}'
	done 
	) | zenity --progress --no-cancel --auto-close --text "ETF is starting..."
    
fi
firefox $ETF_URL 
EOF
fi
#
if [ ! -e $ETF_BIN_FOLDER/etf-stop.sh ] ; then
   sudo cat << EOF > $ETF_BIN_FOLDER/etf-stop.sh
#!/bin/bash
JETTY9=\`/usr/share/jetty9/bin/jetty.sh status | grep "Jetty running pid=" | wc -l\`
if [ \$JETTY9 -eq 1 ]; then
    /usr/share/jetty9/bin/jetty.sh stop
fi
zenity --info --text "ETF stopped"
EOF
fi
#
sudo chmod 755 $ETF_BIN_FOLDER/etf-start.sh
sudo chmod 755 $ETF_BIN_FOLDER/etf-stop.sh
#
#
# Desktop set-up
# =============================================================================
mkdir -p -v "$USER_HOME/Desktop"
#
# icon
# Relies on launchassist in home dir
mkdir -p /usr/share/applications
sudo chmod 777 "/usr/share/applications/"
if [ ! -e /usr/share/applications/etf-start.desktop ] ; then
    cat << EOF > /usr/share/applications/etf-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start ETF
Comment=ETF
Categories=Geospatial;Servers;
Exec=$ETF_BIN_FOLDER/etf-start.sh
Icon=/usr/local/share/icons/$ETF_ICON_NAME
Terminal=false
EOF
fi
#
#
cp -v /usr/share/applications/etf-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/etf-start.desktop"
#
if [ ! -e /usr/local/share/applications/etf-stop.desktop ] ; then
    cat << EOF > /usr/share/applications/etf-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop ETF
Comment=ETF
Categories=Geospatial;Servers;
Exec=$ETF_BIN_FOLDER/etf-stop.sh
Icon=/usr/local/share/icons/$ETF_ICON_NAME
Terminal=false
EOF
fi
#
cp -v /usr/share/applications/etf-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/etf-stop.desktop"
sudo chmod 755 "/usr/share/applications/"
#
#
# Done. Thanks for staying till the end!
#
####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
echo -e "Timing:\nStart: $START\nEnd  : $(date +%M:%S)"

