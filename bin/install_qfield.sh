#!/bin/sh
#############################################################################
#
# Purpose: This script will install QGIS including Python and GRASS support,
#
#############################################################################
# Copyright (c) 2009-2023 The Open Source Geospatial Foundation and others.
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

QFIELD_VERSION=v2.7.5

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p/usr/local/bin
wget -c --progress=dot:mega \
  https://github.com/opengisch/QField/releases/download/${QFIELD_VERSION}/qfield-${QFIELD_VERSION}-linux-x64.AppImage \
  -O /usr/local/bin/qfield
chmod +x /usr/local/bin/qfield

mkdir -p /usr/local/share/icons
wget -c --progress=dot:mega \
  https://github.com/opengisch/QField/raw/${QFIELD_VERSION}/images/icons/qfield_logo.svg \
  -O /usr/local/share/icons/qfield_logo.svg

#### install desktop icon ####
if [ ! -e /usr/share/applications/ch.opengis.qfield.desktop ] ; then
   cat << EOF > /usr/share/applications/ch.opengis.qfield.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=QField
Comment=QField $QFIELD_VERSION
Categories=Application;Education;Geography;
Exec=/usr/local/bin/qfield %F
Icon=/usr/local/share/icons/qfield_logo.svg
Terminal=false
StartupNotify=false
Categories=Education;Geography;Qt;
MimeType=application/x-qgis-project;image/tiff;image/jpeg;image/jp2;application/x-raster-aig;application/x-mapinfo-mif;application/x-esri-shape;
EOF
fi

cp /usr/share/applications/ch.opengis.qfield.desktop "$USER_HOME/Desktop/qfield.desktop"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qfield.desktop"


# add menu item
if [ ! -e /usr/share/menu/qfield ] ; then
   cat << EOF > /usr/share/menu/qfield
?package(qfield):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="QField"\
  command="/usr/local/bin/qfield"\
  icon="/usr/local/share/icons/qfield_logo.svg"
EOF
  update-menus
fi

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
