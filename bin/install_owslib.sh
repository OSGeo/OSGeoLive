#!/bin/sh
#############################################################################
#
# Purpose: This script will install OWSLib
#
#############################################################################
# Copyright (c) 2013-2025 The Open Source Geospatial Foundation and others.
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


echo 'Installing OWSLib ...'

apt-get install --yes python3-owslib

echo 'Downloading geopython logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/geopython.png \
   "https://www.osgeo.org/wp-content/uploads/geopython_logo.png"

echo 'Installing desktop launcher ...'

cat << EOF > /usr/share/applications/owslib.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OWSLib
Comment=OWSLib is a Python package for client programming with Open Geospatial Consortium (OGC) web services
Exec=xdg-open http://localhost/osgeolive/en/quickstart/owslib_quickstart.html
Icon=geopython
Terminal=false
StartupNotify=false
Categories=Application;Education;Geography;OGC
EOF

cp /usr/share/applications/owslib.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/owslib.desktop"

####
./diskspace_probe.sh "`basename $0`" end
