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
# This script will install spatialite in xubuntu

# Running:
# =======
# sudo ./install_spatialite.sh

BUILD_TMP="/tmp/build_spatialite"
INSTALL_FOLDER="/usr/local"
DATA_FOLDER="/usr/local/share/data"
PKG_DATA=$DATA_FOLDER/spatialite
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

########################
### Add repositories ###
if [ ! -e /etc/apt/sources.list.d/ubuntugis.list ] ; then
   cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/
fi
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
apt-get -q update

### setup temp ###
mkdir -p "$BUILD_TMP"
cd "$BUILD_TMP"

###########################
### Install from repo ###
## get spatialite cli and libs
echo "Getting and installing spatialite"
apt-get install --assume-yes spatialite-bin libspatialite3
# The gui programs depend on libjpeg62
apt-get install --assume-yes libjpeg62
# Now the other stuff
# (except for spatialite-gui)
apt-get install --assume-yes librasterlite1 rasterlite-bin # spatialite-gui

##########################
### Now get dependencies for compiling GUI apps
DEV_PKGS="libwxgtk2.8-dev libgeos-dev libgeos++-dev \
  libgeotiff-dev libcairo2-dev libfreexl-dev libspatialite-dev \
  libhpdf-dev librasterlite-dev libproj-dev"
apt-get --yes install $DEV_PKGS

### librasterlite is missing pkg-config file
cat << EOF > /usr/lib/pkgconfig/rasterlite.pc
# Package Information for pkg-config

prefix=/usr
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: rasterlite
Description: Raster Data Source based on SQLite+SpatiaLite
Version: 1.0
Libs: -L\${libdir} -lrasterlite
Cflags: -I\${includedir}
EOF

### Download and compile spatialite-gui 1.5.0 from source
GAIA_URL="http://www.gaia-gis.it/gaia-sins"
PACKAGES="libgaiagraphics-0.4b spatialite_gui-1.5.0-stable spatialite_gis-1.0.0c"
for i in $PACKAGES; do
	wget -c --progress=dot:mega "$GAIA_URL/$i.tar.gz"
	tar xzf $i.tar.gz
	cd $i
	./configure
	make
	make install-strip
	ldconfig
	cd ..
done


##########################
### Sample data ###
# New trento.sqlite downloaded from download.osgeo.org 
OSGEO_URL=http://download.osgeo.org/livedvd/data/spatialite
SQLITE_DB=trento.sqlite.tar.gz
if [ ! -d "$PKG_DATA" ]
then
    echo "Creating $PKG_DATA directory"
    mkdir -p "$PKG_DATA"
fi

wget -N --progress=dot:mega "$OSGEO_URL/$SQLITE_DB"
(cd "$PKG_DATA" && tar xzf "$BUILD_TMP/$SQLITE_DB")

chgrp -R users $PKG_DATA
chmod -R g+w $PKG_DATA

#############################
### GUI start icons ###
mkdir -p /usr/local/share/applications
cp "$BUILD_TMP"/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.desktop \
    /usr/local/share/applications/
cp $BUILD_TMP/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.desktop \
    "$USER_HOME"/Desktop/
chown "$USER.$USER" "$USER_HOME"/Desktop/spatialite-gui.desktop
cp "$BUILD_TMP"/spatialite_gui-1.5.0-stable/gnome_resource/spatialite-gui.png \
    /usr/share/pixmaps/

cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.desktop \
    /usr/local/share/applications/
cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.desktop \
    "$USER_HOME"/Desktop/
chown "$USER.$USER" "$USER_HOME"/Desktop/spatialite-gis.desktop
cp "$BUILD_TMP"/spatialite_gis-1.0.0c/gnome_resource/spatialite-gis.png \
    /usr/share/pixmaps/

#############################
### Clean up
#rm -rf "$BUILD_TMP"
apt-get --yes remove $DEV_PKGS

