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

TMP="/tmp/build_spatialite"
INSTALL_FOLDER="/usr/local"
DATA_FOLDER="/usr/local/share"
PKG_DATA=$DATA_FOLDER/spatialite
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


### setup temp ###
mkdir -p $TMP
cd $TMP

### Download and unpack spatialite ###

## get spatialite
echo "Getting and unpacking spatialite"

BASEURL=http://www.gaia-gis.it/spatialite-2.4.0

wget -r --no-parent --accept *linux-x86-*.tar.gz -c --progress=dot:mega $BASEURL/binaries.html

for i in $(find www.gaia-gis.it -type f); do
  fn=$(basename $i)
  dir=${fn%.tar.gz}
  tar xzf $i
  ## unpack it to /usr overwriting eventual existing copy
  cp -r $dir/* $INSTALL_FOLDER
  rm -rf $dir
done
#rm -rf www.gaia-gis.it


if [ ! -d $PKG_DATA ]
then
    echo "Creating $PKG_DATA directory"
    mkdir $PKG_DATA
fi

# download sample data
wget -c --progress=dot:mega $BASEURL/samples.tar.gz
(cd $PKG_DATA && tar xzf $TMP/samples.tar.gz)

chown user:users $PKG_DATA/*

## start icon
cat << EOF > /usr/share/applications/spatialite-gui.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=SpatiaLite GUI
Comment=SpatiaLite GUI
Categories=Application;Geography;Geoscience;Education;
Exec=spatialite-gui
Icon=gnome-globe
Terminal=false
EOF

cp -a /usr/share/applications/spatialite-gui.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/spatialite-gui.desktop"

cat << EOF > /usr/share/applications/spatialite-gis.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=SpatiaLite GIS
Comment=SpatiaLite GIS
Categories=Application;Geography;Geoscience;Education;
Exec=spatialite-gis
Icon=gnome-globe
Terminal=false
EOF

cp -a /usr/share/applications/spatialite-gis.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/spatialite-gis.desktop"
