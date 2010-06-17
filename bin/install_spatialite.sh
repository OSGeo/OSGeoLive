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


#Add repositories
if [ ! -e /etc/apt/sources.list.d/ubuntugis.list ] ; then
   cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/
fi
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
apt-get update

### setup temp ###
mkdir -p "$TMP"
cd "$TMP"

### Download and unpack spatialite ###

## get spatialite
echo "Getting and unpacking spatialite"

apt-get install --assume-yes spatialite-bin


BASEURL=http://www.gaia-gis.it/spatialite-2.4.0
PACKAGES="
 librasterlite-linux-x86-1.0.tar.gz
 rasterlite-tools-linux-x86-1.0.tar.gz
 spatialite-gis-linux-x86-1.0.0.tar.gz
 spatialite-gui-linux-x86-1.3.0.tar.gz"

for i in $PACKAGES; do
  fn=$(basename $i)
  dir=${fn%.tar.gz}
  # dir=`basename .tar.gz`  # would do the same thing in 1 step
  wget -c --progress=dot:mega "$BASEURL/$i"
  tar xzf "$i"
  ## unpack it to /usr overwriting eventual existing copy
  cp -r "$dir"/* "$INSTALL_FOLDER"
  rm -rf "$dir"
done


if [ ! -d "$PKG_DATA" ]
then
    echo "Creating $PKG_DATA directory"
    mkdir -p "$PKG_DATA"
fi

# download sample data
wget -N --progress=dot:mega "$BASEURL/samples.tar.gz"
(cd "$PKG_DATA" && tar xzf "$TMP/samples.tar.gz")

chown "$USER_NAME":users "$PKG_DATA"/* -R

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
