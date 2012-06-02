#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install OpenLayers 2.11

# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/openLayers/

TMP_DIR="/tmp/build_openlayers"
OL_VERSION="2.11"

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

BUILD_DIR=`pwd`
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

if [ ! -e "OpenLayers-$OL_VERSION.tar.gz" ] ; then
    wget --progress=dot:mega "http://openlayers.org/download/OpenLayers-$OL_VERSION.tar.gz"
else
    echo "... OpenLayers-$OL_VERSION.tar.gz already downloaded"
fi

tar xzf "OpenLayers-$OL_VERSION.tar.gz"

if [ -d "/var/www/openlayers" ] ; then
    echo -n "Removing existing OpenLayers directory (/var/www/openlayers)... "
    rm -fr /var/www/openlayers
    echo "Done"
fi

cp -R OpenLayers-$OL_VERSION/ /var/www/openlayers
chmod -R uga+r /var/www/openlayers


#TODO: Launch script and icon for OpenLayers to take you to a documentation page and examples listing
#Add Launch icon to desktop
cp "$BUILD_DIR"/../doc/images/project_logos/logo-OpenLayers.png \
    /usr/share/pixmaps/openlayers.png

if [ ! -e /usr/share/applications/openlayers.desktop ] ; then
   cat << EOF > /usr/share/applications/openlayers.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenLayers Examples
Comment=Sample constructions
Categories=Application;Internet;
Exec=firefox http://localhost/openlayers/examples/
Icon=openlayers
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/openlayers.desktop "$USER_HOME/Desktop/"



#TODO: Create local example that uses data from the many wms/wfs sources on the live disc


echo "Finished installing OpenLayers $OL_VERSION."

