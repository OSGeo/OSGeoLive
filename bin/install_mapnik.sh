#!/bin/sh
# Copyright (c) 2009-2016 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
#
# About:
# =====
# This script will install Mapnik library and Python bindings
# and TileLite for a demo 'World Borders' application
#
# Requires:
# =========
# python, wget, unzip
#
# Uninstall:
# ==========
# sudo apt-get remove python-mapnik
# rm -rf /usr/local/lib/python2.7/dist-packages/tilelite*
# rm -rf /usr/local/share/mapnik/
# rm /usr/local/bin/liteserv.py

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


# package name change in precise
apt-get install --yes python-mapnik python-werkzeug

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


mkdir -p "$TMP"
cd "$TMP"

## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again"
   exit 1
fi

if [ ! -d "$MAPNIK_DATA" ] ; then
   echo "Creating $MAPNIK_DATA directory"
   mkdir "$MAPNIK_DATA"
fi

# download TileLite sources
## some problems with filenames, substitute package --Live 4.5b3
#wget -N --progress=dot:mega http://bitbucket.org/springmeyer/tilelite/get/tip.zip
#unzip -o tip.zip
#rm tip.zip # We wish to backup files downloaded. The tmp directory is
#           #   automatically emptied upon computer shutdown.
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/mapnik/tilelite.tgz"

tar xzf tilelite.tgz
cd "$TMP/tilelite"

# install tilelite using the standard python installation tools
python setup.py install # will install 'tilelite.py' in dist-packages and 'liteserv.py' in default bin directory

# copy TileLite demo application and data to 'mapnik' subfolder of DATA_FOLDER
mkdir -p "$MAPNIK_DATA"/demo/
cp demo/* "$MAPNIK_DATA"/demo/
#truly local only demo relies on jquery and openlayers from other installers
cp "$BUILD_DIR/../app-conf/mapnik/local.html" "$MAPNIK_DATA"/demo/

# now get rid of temporary unzipped sources
cd "$TMP"
rm -rf "$TMP/tilelite"

# Create startup script for TileLite Mapnik Server
cat << EOF > "$BIN/mapnik_start_tilelite.sh"
#!/bin/sh
liteserv.py --port 8012 /usr/local/share/mapnik/demo/population.xml
EOF

chmod 755 "$BIN/mapnik_start_tilelite.sh"


## Create Desktop Shortcut for starting TileLite Mapnik Server in shell
# Note: TileLite when run with the 'liteserv.py' script is in development
# mode and is intended to be run within a viewable terminal, thus 'Terminal=true'
cat << EOF > /usr/share/applications/mapnik-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Mapnik & TileLite
Comment=Mapnik tile-serving using TileLite Server
Categories=Application;Geography;Geoscience;Education;
Exec=mapnik_start_tilelite.sh
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
