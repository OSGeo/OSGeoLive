#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will install marble

echo "==============================================================="
echo "install_viking.sh"
echo "==============================================================="

if [ -z "$USER_NAME" ] ; then 
   USER_NAME="user" 
fi 
USER_HOME="/home/$USER_NAME"


apt-get --assume-yes install viking gpsbabel gpsd


# cache snafu in versions prior to 1.2.2
mkdir "$USER_HOME"/.viking
echo "viking.globals.download_tile_age=604800" > "$USER_HOME"/.viking/viking.prefs
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/.viking
cp -r "$USER_HOME"/.viking /etc/skel/
chown -R root.root /etc/skel/.viking


# copy icon to Desktop
cp /usr/share/applications/viking.desktop "$USER_HOME/Desktop/"

