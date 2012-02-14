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
# This script will install geopublisher via a Debian Repository .deb

# Running:
# =======
# "geopublisher" from Application -> Science -> Geopublisher

# Requirements:
# =======
# Any Java 1.6, Sun preferred

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

cp ../sources.list.d/geopublishing.list /etc/apt/sources.list.d/
# Get and import the key that the .deb packages are signed with
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7450D04751B576FD
apt-get -q update


# Install Geopublisher and documentation
apt-get -q install --yes --no-install-recommends geopublisher geopublishing-doc

# Now we create a .properties file which predefines that Geopublisher open-file-dialog will start in the directory recommended in the quickstart 
mkdir -p $USER_HOME/.Geopublisher
echo "LastOpenAtlasFolder=$USER_HOME/Desktop/ChartDemoAtlas" \
   > $USER_HOME/.Geopublisher/geopublisher.properties

# Change the owner of the user's local Geopublisher settings to user:user
chown -R $USER_NAME:$USER_NAME $USER_HOME/.Geopublisher

# Create a desktop icon
cp /usr/share/applications/geopublisher.desktop "$USER_HOME/Desktop/"
chown $USER_NAME.$USER_NAME "$USER_HOME/Desktop/geopublisher.desktop"


# share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
ln -s /usr/share/doc/geopublishing-doc/tutorial_Geopublisher_1 \
      /usr/local/share/data/vector/geopublisher

