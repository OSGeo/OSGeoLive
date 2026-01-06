#!/bin/sh
# Copyright (c) 2009-2026 The Open Source Geospatial Foundation and others.
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

# About:
# =====
# This script will install gvSIG 2.4.0 using a deb package.

#set -x
GVSIG_VERSION="2.4.0-2850-2"
ARCH="amd64"
GVSIG_BASE_URL="http://download.osgeo.org/livedvd/data/gvsig/"


if [ -x "./diskspace_probe.sh" ] ; then
  ./diskspace_probe.sh "`basename $0`" begin
fi
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"

GVSIG_PACKAGE="gvsig-desktop_${GVSIG_VERSION}_${ARCH}.deb"

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again"
   exit 1
fi

# create tmp folders
TMP="/tmp/build_gvsig"
if [ ! -d "$TMP" ] ; then
   mkdir "$TMP"
fi
cd "$TMP"

# get deb package
if [ ! -e "$GVSIG_PACKAGE" ] ; then
   wget -c --progress=dot:mega "$GVSIG_BASE_URL/$GVSIG_PACKAGE"
fi

# remove it if it's present at the system
dpkg -l gvsig-desktop  > /dev/null 2> /dev/null
if [ $? -eq 0 ] ; then
   echo "Purging previous versions of gvSIG"
   apt-get -y purge gvsig-desktop
fi

if [ -d "$USER_HOME/gvSIG" ] ; then
   rm -rf "$USER_HOME/gvSIG"
fi

# install the deb package forcing the version
echo "Installing gvSIG package"
dpkg -i "$GVSIG_PACKAGE"

if [ $? -ne 0 ] ; then
   echo "ERROR: gvsig package failed to install"
   exit 1
fi

rm -f "$TMP/$GVSIG_PACKAGE"

# place a gvSIG icon on desktop
rm -f /usr/share/applications/gvsig-desktop.desktop

cat << EOF > /usr/share/applications/gvsig-desktop.desktop
[Desktop Entry]
Name=gvSIG desktop
Version=${GVSIG_VERSION}
Exec=gvsig-desktop
Comment=
Icon=/usr/share/pixmaps/gvsig-desktop.png
Type=Application
Terminal=false
StartupNotify=true
Encoding=UTF-8
Categories=Graphics;
EOF

cp -a /usr/share/applications/gvsig-desktop.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/gvsig-desktop.desktop"
chmod +x "$USER_HOME/Desktop/gvsig-desktop.desktop"

# the package for gvSIG contains a static library for gdal
# this is not useful as we are not building anything. gvSIG also contains
# a shared library. Ideally this would use the debian version instead.
# removing this file is an ugly fix - a cleaner way would be fixing this in de package.
# removing this file saves 107Mb
# rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-2-${ARCH}/gvSIG/extensiones/org.gvsig.raster.gdal.app/gdal/bin/libgdal.a"
# rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-3-${ARCH}/gvSIG/extensiones/org.gvsig.raster.gdal.app/gdal/bin/libgdal.a"
# rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-2-${ARCH}/gvSIG/extensiones/org.gvsig.raster.ermapper.app"
# rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-3-${ARCH}/gvSIG/extensiones/org.gvsig.raster.ermapper.app"

####
if [ -x "$BUILD_DIR"/diskspace_probe.sh ] ; then
  "$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
fi
