#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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
# About:
# =====
# This script will install ZOO Project
#
# Requires: Apache2, GeoServer (for the demo only)


./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


TMP_DIR=/tmp/build_zoo
if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


apt-get --assume-yes install libmozjs185-1.0

# Download ZOO Project deb file.
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/zoo/zoo-project_1.3.0-2_i386.deb"

dpkg -i zoo-project_1.3.0-2_i386.deb

a2enmod rewrite

cp /usr/share/applications/zoo-project.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/zoo-project.desktop"

cd /usr/lib/cgi-bin
ldconfig

# Reload Apache
/etc/init.d/apache2 force-reload

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
