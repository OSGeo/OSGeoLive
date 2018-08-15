#!/bin/sh
#############################################################################
#
# Purpose: This script will install Mapnik library, Python bindings and
# Tilestache for a demo 'World Borders' application
#
#############################################################################
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation and others.
#
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
#############################################################################

#
# Requires:
# =========
# python, wget, unzip
#
# Uninstall:
# ==========
# sudo apt-get remove python-mapnik tilestache python-modestmaps
# rm -rf /usr/local/share/mapnik/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp/build_mapnik"
DATA_FOLDER="/usr/local/share"
MAPNIK_DATA="$DATA_FOLDER/mapnik"
BIN="/usr/local/bin"

apt-get install --yes python-mapnik tilestache libjs-modestmaps

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

# Patch for #2096
sed -i -e 's/engine = mapnik.FontEngine.instance()/#engine = mapnik.FontEngine.instance()/' /usr/lib/python2.7/dist-packages/TileStache/Mapnik.py

mkdir -p "$TMP"
cd "$TMP"

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again"
   exit 1
fi

if [ ! -d "$MAPNIK_DATA" ] ; then
   echo "Creating $MAPNIK_DATA directory"
   mkdir "$MAPNIK_DATA"
fi

# download Tilestache demo
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/mapnik/tilestache_demo.tar.gz"

tar zxf tilestache_demo.tar.gz
mkdir -p "$MAPNIK_DATA"/demo/
cp demo/* "$MAPNIK_DATA"/demo/

# now get rid of temporary unzipped sources
cd "$TMP"
rm -rf "$TMP/demo"

# Create startup script for TileStache Mapnik Server
cat << EOF > "$BIN/mapnik_start_tilestache.sh"
#!/bin/sh
tilestache-server -c /usr/local/share/mapnik/demo/tilestache.cfg -p 8012
EOF

chmod 755 "$BIN/mapnik_start_tilestache.sh"


## Create Desktop Shortcut for starting Tilestache Server in shell
cat << EOF > /usr/share/applications/mapnik-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Mapnik & TileStache
Comment=Mapnik tile-serving using TileStache Server
Categories=Application;Geography;Geoscience;Education;
Exec=mapnik_start_tilestache.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF

cp -a /usr/share/applications/mapnik-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/mapnik-start.desktop"

# Create Desktop Shortcut for Basic Intro page and Demo
cat << EOF > /usr/share/applications/mapnik-intro.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapnik Introduction
Comment=Mapnik Introduction
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/osgeolive/en/overview/mapnik_overview.html
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/mapnik-intro.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/mapnik-intro.desktop"

# share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
rm -f /usr/local/share/data/vector/world_merc
ln -s /usr/local/share/mapnik/demo \
      /usr/local/share/data/vector/world_merc

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
