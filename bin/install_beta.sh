#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# About:
# =====
# This script installs beta packages and creates new submenu.
# Valid for Xubuntu 9.10
# 
# I believe menu descriptions have different paths and structure in 
# each Linux distribution. After some tests, I don't think the command
# "?package(name):needs..." and "update-menus" are enough to create
# a new submenu, so this script will have to be adapted in future
# versions of the live DVD.
# 
# INSTRUCTIONS:
# 
# Copy your beta software install script to the folder ./beta_software  
# Also create in that folder your .desktop file using
# the existing one as template. Your script should not create two .desktop files,
# only the one inside the folder ./beta_software
# Add a call to your install sh script here (under "for SCRIPT in \")
#
# Running:
# =======
#
# sudo ./install_beta.sh
#
# --------------- Start: ---------------------


echo "===================================================================="
echo "Starting installation of beta software..."
echo "===================================================================="
echo Disk Usage1:, main.sh, `df | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, main.sh, `df | grep " /$" | sed -e "s/  */,/g"`, `date`
	
cd beta_software

for SCRIPT in \
    ./install_ugvsigmobile.sh \
    ./install_qgis_mapserver.sh \
; do
  echo "===================================================================="
  echo Starting: $SCRIPT
  echo "===================================================================="
  sh $SCRIPT
  if [ $? -ne 0 ] ; then
    echo '!!! possible failure in '"$SCRIPT" >> /tmp/build_gisvm_error.log
  fi
  echo Finished: $SCRIPT
  echo
  # Prints in MB blocks now, -h might miss changes less than 1GB
  echo Disk Usage1:, $SCRIPT, `df -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
  echo Disk Usage2:, $SCRIPT, `df -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
done


##
## Menu is now handled by install_desktop.sh ##

exit 0



# dead code:

# #################################################
# #################################################
# Do not edit from this point
# #################################################
# #################################################

# Initial check. This file MUST exist or we got it all wrong...
echo "Checking presence of essential file..."
if [ ! -e /etc/xdg/xubuntu/menus/xfce-applications.menu ] ; then
    echo "ERROR: Did not find Xubuntu main menu description!!!"
    exit 1
fi

echo "Checking presence of essential file: OK"

echo "Adding new submenu description..."
# add submenu description 
if [ ! -e /usr/share/desktop-directories/xfce-geobeta.directory ] ; then
    cp ./config_files/xfce-geobeta.directory /usr/share/desktop-directories
fi

echo "Backup of Xubuntu menu description..."
# backup default xubuntu menu description
if [ ! -e /etc/xdg/xubuntu/menus/xfce-applications.menu.backup ]
then
    mv /etc/xdg/xubuntu/menus/xfce-applications.menu /etc/xdg/xubuntu/menus/xfce-applications.menu.backup
else
    rm /etc/xdg/xubuntu/menus/xfce-applications.menu
fi

echo "Replacing Xubuntu menu description..."
# replace xubuntu menu description (simply adds a new XML element (geobeta submenu)
cp ./config_files/xfce-applications.menu /etc/xdg/xubuntu/menus/xfce-applications.menu

echo "Adding red icon for new submenu..."
# add beta submenu icon (red planet)
if [ ! -e /usr/share/icons/geobeta.png ] ; then
    cp ./config_files/geobeta_48.png /usr/share/icons/geobeta.png
fi

echo "Copying .desktop files to right folder..."
# Copy .desktop files to app folder
cp ./*.desktop /usr/share/applications

# Now, if a <package>.desktop has:
#
# Categories=Geobeta;...
#
# it should appear in the geobeta submenu

echo "Finished: install_beta.sh"
