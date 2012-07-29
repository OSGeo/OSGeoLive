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
apt-get -q update

# Install AtlasStyler and documentation
apt-get -q install --yes --no-install-recommends atlasstyler geopublishing-doc

# Now we download some predefined symbols for atlasstyler because the user
#  is probably off-line
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p "$USER_HOME/.AtlasStyler"

wget --cut-dirs=0 -nH -q -c -r \
   http://freemapsymbols.org/ -A "*.sld" \
   --exclude-directories="svg" \
   -P "$USER_HOME/.AtlasStyler/templates"

# Now we create a .properties file which predefines that AtlasStyler
#  open-file-dialog will start in the data directory, and the export
#  directory points to the desktop.
echo "lastImportDirectory=$USER_HOME/data/natural_earth" \
   > "$USER_HOME/.AtlasStyler/atlasStyler.properties"
echo "lastExportDirectory=$USER_HOME/Desktop" \
   >> "$USER_HOME/.AtlasStyler/atlasStyler.properties"

# Also predefine, that adding a PG datasource will open with the OSGeoLive defaults
echo "dbList=postgis|postgresql\://localhost/user|localhost|5432|user|user|natural_earth|true|public@" \
   >> "$USER_HOME/.AtlasStyler/atlasStyler.properties"
echo "wfsList=http\://localhost\:8082/geoserver/ows 1.0.0|http\://localhost\:8082/geoserver/ows|v1_0_0|0|null|false|null|admin|geoserver@" \
   >> "$USER_HOME/.AtlasStyler/atlasStyler.properties"

# Change the owner of the user's local AtlasStyler settings to user:user
chown -R $USER_NAME:$USER_NAME "$USER_HOME/.AtlasStyler"

# Create a desktop icon
cp /usr/share/applications/atlasstyler.desktop "$USER_HOME/Desktop/"
chown $USER_NAME.$USER_NAME "$USER_HOME/Desktop/atlasstyler.desktop"


## for some unknown reason the startup script is losing its exe bit on the ISO ?!!
#   (trac #771)
cat << EOF >> /usr/bin/atlasstyler

# try, try again ..
if [ \$? -ne 0 ] ; then
   . ./start_AtlasStyler.sh \${1} \${2} \${3} \${4} \${5} \${6} \${7} \${8} \${9} \${10} \${11} \${12} \${13} \${14} \${15} \${16} \${17}
fi
EOF

#?or? if [ ! -x /usr/share/atlasstyler/start_Atlasstyler.sh ] ; then
