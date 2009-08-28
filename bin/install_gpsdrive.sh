#!/bin/sh
# Copyright (c) 2009 by Hamish Bowman, and the Open Source Geospatial Foundation
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install GpsDrive
#    written by H.Bowman <hamish_b  yahoo com>
#    GpsDrive homepage: http://www.gpsdrive.de
#


#!#!# EXPERIMENTAL #!#!#


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_gpsdrive

#### install program ####

PACKAGES="gpsd gpsdrive"

apt-get install $PACKAGES




#######################
## FIXME: packaged version (2.10pre4) is long out of date. build 2.10pre7.
##  I'm not sure if pre4 will handle the map tiles in separate subdirs
if [ 0 -eq 1 ] ; then
VERSION="2.10pre7"

mkdir "$TMP_DIR"
cd "$TMP_DIR"

wget -nv http://www.gpsdrive.de/packages/gpsdrive-$VERSION.tar.gz

tar xzf gpsdrive-$VERSION.tar.gz
if [ $? -eq 0 ] ; then
  \rm gpsdrive-$VERSION.tar.gz
fi

cd gpsdrive-$VERSION


# FIXME:
# - whatever the command is to install build-depends for a package ...
#    keep a record, we'll rm the -dev packages later
# - debuild and friends need to be installed & later removed by main.sh

# - apply any patches

debuild binary
if [ $? -ne 0 ] ; then
   echo "An error occurred building package. Aborting install."
   exit 1
fi

cd ..

# or some such package...
wget -nv "http://www.gpsdrive.de/debian/pool/squeeze/openstreetmap-map-icons_16908_all.deb"

dpkg -i gpsdrive*deb  openstreetmap-map-icons_16908_all.deb
fi
##
## end self-build
#######################




#### install data ####
mkdir "$USER_HOME/.gpsdrive"

# minimal icon set
wget -nv "http://downloads.sourceforge.net/project/gpsdrive/additional%20data/minimal%20icon%20set/openstreetmap-map-icons-minimal.tar.gz?use_mirror=internode"
cd /
tar xzf "$TMP_DIR"/openstreetmap-map-icons-minimal.tar.gz
cd "$TMP_DIR"

#debug dummy copy of geoinfo.db
#tar xzf openstreetmap-map-icons-minimal.tar.gz usr/share/icons/map-icons/geoinfo.db
#cp usr/share/icons/map-icons/geoinfo.db "$USER_HOME/.gpsdrive/"
#  .gpsdrive/gpsdriverc: geoinfofile = $USER_HOME/.gpsdrive/geoinfo.db

cat << EOF > "$USER_HOME/.gpsdrive/gpsdriverc"
lastlong = 151.2001
lastlat = -33.8753
autobestmap = 0
EOF


# Sydney maps
wget -nv "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/gpsdrive_syd_tileset.tar.gz"

cd "$USER_HOME/.gpsdrive/"
tar xzf "$TMP_DIR"/gpsdrive_syd_tileset.tar.gz

if [ $? -eq 0 ] ; then
   rm -rf "$TMP_DIR"
fi


chown -R $USER_NAME:$USER_NAME "$USER_HOME/.gpsdrive"

cp /usr/share/applications/gpsdrive.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/gpsdrive.desktop"


echo "Finished installing GpsDrive."
