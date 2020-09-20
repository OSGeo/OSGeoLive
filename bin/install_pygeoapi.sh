#!/bin/sh
#############################################################################
#
# Purpose: This script will install pygeoapi
#
#############################################################################
# Copyright (c) 2019-2020 The Open Source Geospatial Foundation and others.
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

# Requires: Apache2, python-lxml, python-shapely and python-sqlalchemy

./diskspace_probe.sh "`basename $0`" begin
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


echo 'Installing pygeoapi ...'

apt-get install --yes python3-pygeoapi

echo 'Downloading pycsw logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/pygeoapi.png \
      "https://github.com/geopython/pygeoapi.io/raw/master/docs/img/pygeoapi-icon.png"

echo 'Installing desktop launcher ...'

cat << EOF > /usr/share/applications/pygeoapi.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=pygeoapi
Comment=pygeoapi OGC API server
Exec=xdg-open http://localhost/pycsw/tests/index.html
Icon=pygeoapi
Terminal=false
StartupNotify=false
Categories=Application;Education;Geography
EOF

cp /usr/share/applications/pygeoapi.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/pygeoapi.desktop"

####
./diskspace_probe.sh "`basename $0`" end
