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

# Author: Stefan A. Krüger

# About:
# =====
# This script will install the geopublishing.deb which contains the AtlasStyler SLD editor and the Geopublisher application. It will also
# download the openmapsymbols for AtlasStyler to the local ~/.AtlasStyler/templates directory.

# Running:
# =======
# "atlasstyler" or "geopublisher" or Application -> Science -> Geopublisher/AtlasStyler

# Requirements:
# =======
# Latest Sun JRE 1.6 

# Get the sources list file (may overwrite existing sources file, but that is no problem)
# Uses lsb_release so that the script will run unchanged for "lucid" and later versions of ubuntu/debian
apt-get install --yes lsb-release
wget -nv --output-document="/etc/apt/sources.list.d/geopublishing.list" \
   "http://www.geopublishing.org/sources.list.d/$(lsb_release -cs).list"

# Get and import the key that the .deb packages are signed with
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD

# Install Geopublisher and AtlasStyler and documentation
apt-get update --yes
apt-get install --yes --no-install-recommends geopublishing geopublishing-doc

# The above was simple : just installing .deb

# Now we download some predefined symbols for atlasstyler because the user is probably off-line
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


wget --cut-dirs=1 -nH -q -c -r http://en.geopublishing.org/openmapsymbols/ -A "*.sld" --exclude-directories="openmapsymbols/svg" -P $USER_HOME/.AtlasStyler/templates
chown -R $USER_NAME:$USER_NAME $USER_HOME/.AtlasStyler 

