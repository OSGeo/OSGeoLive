#!/bin/sh
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation and others.
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
# This script will install gvSIG 2.2 using a deb package.

# Changelog:   "svn log install_gvsig.sh --limit 10"
# ===========
# 2015-08-19
#  * Updated to gvSIG 2.2
#
# 2014-02-02
#  * Updated to gvSIG 2.1
#
# 2013-06-16
#   * Updated to gvSIG 2.0, no default project yet
#
# 2012-12-07
#   * Updated to use gvSIG 1.12 package
#
# 2012-07-15
#   * Updated to use a new 1.11 package with dependencies
#     solved and minor changes to this script
#
# 2011-07-03:
#   * updated to gvSIG 1.11, removed docs (BN 1305)
#
# 2011-01-24:
#   * updated to gvSIG 1.10 final version (BN 1264)
#
# 2010-07-02:
#   * updated to gvSIG 1.10 (BN 1255)
#
# 2010-03-13:
#   * removed usage of source command
#
# 2010-01-04: adapting the script to 1.9 stable release (jsanz@osgeo.org)
#   * Adapted dependencies
#   * Changed to the "with-jre" version because the Xubuntu 9.10 version
#     doesn't have the packages of Java 1.5

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_gvsig.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_gvsig.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"

if [ "$ARCH" = "i386" ] ; then
    GVSIG_PACKAGE="gvsig-desktop_2.2.0-2313-3_${ARCH}.deb"
fi

if [ "$ARCH" = "amd64" ] ; then
    GVSIG_PACKAGE="gvsig-desktop_2.2.0-2313-2_${ARCH}.deb"
fi

#GVSIG_PACKAGE="gvsig_2.1.0-2218_${ARCH}_BN2.deb"
#GVSIG_URL="http://aiolos.survey.ntua.gr/gisvm/dev/"
GVSIG_URL="http://download.osgeo.org/livedvd/data/gvsig/"
#GVSIG_URL="http://downloads.gvsig.org/download/gvsig-desktop/other-dists/osgeo-live"
#GVSIG_URL="https://www.dropbox.com/s/6ujajdxa048pgii/"

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
   wget -c --progress=dot:mega "$GVSIG_URL/$GVSIG_PACKAGE"
fi

# remove it if it's present at the system
dpkg -l gvsig  > /dev/null 2> /dev/null
if [ $? -eq 0 ] ; then
   echo "Purging previous versions of gvSIG"
   apt-get -y purge gvsig
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

rm "$TMP/$GVSIG_PACKAGE"

# place a gvSIG icon on desktop
rm /usr/share/applications/gvsig-desktop.desktop

cat << EOF > /usr/share/applications/gvsig-desktop.desktop
[Desktop Entry]
Name=gvSIG desktop
Version=2.2.0-2313
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
rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-2-${ARCH}/gvSIG/extensiones/org.gvsig.raster.gdal.app/gdal/bin/libgdal.a"
rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-3-${ARCH}/gvSIG/extensiones/org.gvsig.raster.gdal.app/gdal/bin/libgdal.a"
rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-2-${ARCH}/gvSIG/extensiones/org.gvsig.raster.ermapper.app"
rm -rf "/usr/local/lib/gvsig-desktop/2.2.0-2313-3-${ARCH}/gvSIG/extensiones/org.gvsig.raster.ermapper.app"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
