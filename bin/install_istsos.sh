#!/bin/sh
# Copyright (c) 2016-2020 The Open Source Geospatial Foundation and others.
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
# This script will install istSOS server

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"
BUILD_DIR=`pwd`

echo "Installing istSOS package"
apt-get install --assume-yes python3-istsos

echo "Installing istSOS icon"
cp -f /usr/share/istsos/interface/admin/images/istsos-logo.png \
       /usr/share/icons/

## desktop launcher
cat << EOF > /usr/share/applications/istsos.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=istSOS
Comment=istSOS server
Categories=Application;Geography;Geoscience;Education;
Exec=xdg-open http://localhost/istsos/admin
Icon=/usr/share/icons/istsos-logo.png
Terminal=false
EOF

cp -a /usr/share/applications/istsos.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/istsos.desktop"

####
./diskspace_probe.sh "`basename $0`" end
