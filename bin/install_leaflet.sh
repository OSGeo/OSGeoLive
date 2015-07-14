#!/bin/sh
# Copyright (c) 2013 The Open Source Geospatial Foundation.
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
# This script will install leaflet

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

#add-apt-repository --yes ppa:johanvdw/leafletjs
apt-get update
apt-get --assume-yes install libjs-leaflet
#add-apt-repository --yes --remove ppa:johanvdw/leafletjs

ln -s /usr/share/javascript/leaflet/ /var/www/html/leaflet

#add demo file
cp -f ../app-conf/leaflet/leaflet-demo.html /var/www/html/


### install desktop icons ##
echo "Installing Leaflet icon"
cp -f "$USER_HOME/gisvm/app-conf/leaflet/leafletjs_logo.png" \
       /usr/share/icons/

## start icon
cat << EOF > /usr/share/applications/leaflet.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Leaflet
Comment=LeafletJS Examples
Categories=Application;Internet;
Exec=firefox http://localhost/osgeolive/en/quickstart/leaflet_quickstart.html http://localhost/leaflet-demo.html
Icon=/usr/share/icons/leafletjs_logo.png
Terminal=false
EOF

cp -a /usr/share/applications/leaflet.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/leaflet.desktop"

####
./diskspace_probe.sh "`basename $0`" end
