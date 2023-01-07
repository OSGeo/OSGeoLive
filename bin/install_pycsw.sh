#!/bin/sh
#############################################################################
#
# Purpose: This script will install pycsw
#
#############################################################################
# Copyright (c) 2013-2023 The Open Source Geospatial Foundation and others.
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


echo 'Installing pycsw ...'

apt-get install --yes pycsw pycsw-doc javascript-common

echo 'Downloading pycsw logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/pycsw.png \
   "https://github.com/geopython/pycsw/raw/master/docs/_static/favicon/android-chrome-192x192.png"

echo 'Installing desktop launcher ...'

cat << EOF > /usr/share/applications/pycsw.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=pycsw
Comment=pycsw catalog server
Exec=xdg-open http://localhost/pycsw/tests/index.html
Icon=pycsw
Terminal=false
StartupNotify=false
Categories=Application;Education;Geography;CSW
EOF

cp /usr/share/applications/pycsw.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/pycsw.desktop"

####
./diskspace_probe.sh "`basename $0`" end
