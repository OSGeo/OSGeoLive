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

# Author: Stefan A. Tzeggai

# About:
# =====
# This script will install AtlasStyler SLD editor. It will also download the openmapsymbols 
# for AtlasStyler to the local ~/.AtlasStyler/templates directory.

# Running:
# =======
# "atlasstyler" from Application -> Science -> AtlasStyler

# Requirements:
# =======
# Any Java 1.6, Sun preferred

cp ../sources.list.d/geopublishing.list /etc/apt/sources.list.d/
# Get and import the key that the .deb packages are signed with
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD
apt-get update

# Install AtlasStyler and documentation
apt-get install --yes --no-install-recommends atlasstyler geopublishing-doc

# Now we download some predefined symbols for atlasstyler because the user is probably off-line
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

mkdir -p $USER_HOME/.AtlasStyler

wget --cut-dirs=1 -nH -q -c -r \
   http://en.geopublishing.org/openmapsymbols/ -A "*.sld" \
   --exclude-directories="openmapsymbols/svg" \
   -P $USER_HOME/.AtlasStyler/templates

# Now we create a .properties file which predefines that AtlasStyler open-file-dialog will start in the data directory, and the export directory points to the desktop.
echo "lastImportDirectory=$USER_HOME/data/natural_earth" > $USER_HOME/.AtlasStyler/atlasStyler.properties
echo "lastExportDirectory=$USER_HOME/Desktop" >> $USER_HOME/.AtlasStyler/atlasStyler.properties
# Also predefine, that adding a PG datasource will open with the OSGeoLive defaults
echo "lastPgHost=localhost" >> $USER_HOME/.AtlasStyler/atlasStyler.properties
echo "lastPgTable=10m_land" >> $USER_HOME/.AtlasStyler/atlasStyler.properties
echo "lastPgDatabase=natural_earth" >> $USER_HOME/.AtlasStyler/atlasStyler.properties
echo "lastPgUsername=user" >> $USER_HOME/.AtlasStyler/atlasStyler.properties
echo "lastPgPort=5432" >> $USER_HOME/.AtlasStyler/atlasStyler.properties

# Change the owner of the user's local AtlasStyler settings to user:user
chown -R $USER_NAME:$USER_NAME $USER_HOME/.AtlasStyler

# Create a desktop icon
cp /usr/share/applications/atlasstyler.desktop "$USER_HOME/Desktop/"
chown $USER_NAME.$USER_NAME "$USER_HOME/Desktop/atlasstyler.desktop"
