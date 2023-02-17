#!/bin/sh
#############################################################################
#
# Purpose: This script will install GRASS GIS 8
#
#############################################################################
# Copyright (c) 2014-2023 The Open Source Geospatial Foundation and others.
# Author: H.Bowman <hamish_b  yahoo com>
#
# Licensed under the GNU LGPL version >= 2.1.
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
#############################################################################


#
# This does not attempt to install QGIS-plugin infrastructure, that is
#  done in install_qgis.sh. Your QGIS packages will have to have been
#  built with grass8-enabled plugins.
#
# ***
# This script is intended to be run by the User on an existing live disc,
#  Not at build time of the disc. The North Carolina GRASS 7
#  sample dataset will also be downloaded and installed. A result of all
#  this is that users of a non-persistent ISO boot will have everything
#  on the RAM drive, which may be quite limited to begin with depending
#  on your computer's available RAM. Users with >2gb RAM shouldn't have
#  to worry, but those on old netbooks might. If run from a persistent VM
#  or 8gb USB things should be ok too.
# ***

# FIXME: grass version parsing

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_grass
mkdir "$TMP_DIR"

apt-get --quiet update
apt-get --yes install grass-core grass-gui grass-doc grass-dev libgdal-grass

cp /usr/share/applications/grass82.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/grass82.desktop"

cp /usr/share/applications/grass82.desktop \
  /usr/local/share/applications/osgeo-grass82.desktop

#### get sample data ####

# put static data in /usr/local ..
mkdir -p /usr/local/share/grass
if [ ! -d "$USER_HOME/grassdata" ] ; then
  mkdir -p "$USER_HOME/grassdata"
  chown "$USER_NAME.$USER_NAME" "$USER_HOME/grassdata"
fi

# # NC08 for G7 is 141mb; nc_basic_spm_grass7 is 50mb; Spearfish is 21mb
# FILE="spearfish_grass70data-0.3"
# FOLDER_NAME="spearfish60_grass7"
# #FILE="north_carolina/nc_basic_spm_grass7"
# #FILE="north_carolina/nc_spm_08_grass7"
# #FOLDER_NAME="nc_spm_08_grass7"
# 
# cd "$TMP_DIR"
# wget -c --progress=dot:mega \
#      "http://grass.osgeo.org/sampledata/$FILE.tar.gz"
# 
# cd /usr/local/share/grass/
# BASE=`echo "$FILE" | sed -e 's+.*/++'`
# tar xzf "$TMP_DIR/$BASE.tar.gz"
# chown -R root.users "$FOLDER_NAME"
# chmod -R a+rX "$FOLDER_NAME"
# 
# # free disk space ASAP
# rm "$TMP_DIR"/*.tar.gz

##############
# New dataset#
##############
#This dataset is maintained by GRASS community
FILE="nc_basic_spm_grass7.zip"
FOLDER_NAME="nc_basic_spm_grass7"
cd "$TMP_DIR"
wget -c --progress=dot:mega \
     "https://grass.osgeo.org/sampledata/north_carolina/nc_basic_spm_grass7.zip"
unzip -q "$FILE" -d /usr/local/share/grass/
cd /usr/local/share/grass/
rm "$TMP_DIR"/*.zip
chown -R root:users /usr/local/share/grass
chmod -R 0775 /usr/local/share/grass

#############

cd "$USER_HOME/grassdata"
mkdir "$FOLDER_NAME"
cd "$FOLDER_NAME"
cp -r "/usr/local/share/grass/$FOLDER_NAME/user1/" .
ln -s "/usr/local/share/grass/$FOLDER_NAME/PERMANENT" .
# only in nc_spm_08_grass7
#ln -s "/usr/local/share/grass/$FOLDER_NAME/landsat" .
cd ..
chown -R "$USER_NAME.$USER_NAME" "$FOLDER_NAME"



#### preconfig setup ####
mkdir "$USER_HOME/.grass8"

cat << EOF > "$USER_HOME/.grass8/rc"
GISDBASE: $USER_HOME/grassdata
LOCATION_NAME: $FOLDER_NAME
MAPSET: user1
GRASS_GUI: wxpython
EOF

# # buggy (prompt.py not found), so disable it for now
# echo "unset PROMPT_COMMAND" > "$USER_HOME/.grass7/bashrc"

chown -R $USER_NAME.$USER_NAME "$USER_HOME/.grass8"

mkdir -p "$USER_HOME/grassdata/addons"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/grassdata/addons"

#### make gtk happy
mkdir -p "$USER_HOME/.config/gtk-2.0"
chown $USER_NAME.$USER_NAME "$USER_HOME/.config/gtk-2.0"
chmod go-rx "$USER_HOME/.config/gtk-2.0"


# cleanup
rmdir "$TMP_DIR"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

