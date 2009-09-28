#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# About:
# =====
# This script will install Mapnik library and Python bindings
# and TileLite for a demo 'World Borders' application
#
# Running:
# =======
# sudo ./install_mapnik.sh
#
# Requires:
# =========
# python, wget, unzip
#
# Uninstall:
# ==========
# rm -rf /usr/local/lib/python2.6/dist-packages/tilelite*
# rm /usr/local/bin/liteserv.py

# will fetch Mapnik 0.5.1 on Ubuntu 9.04
apt-get install --yes python-mapnik


# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp"
DATA_FOLDER="/usr/local/share"
MAPNIK_DATA=$DATA_FOLDER/mapnik
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
BIN="/usr/bin"

cd "$TMP"

## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

if [ ! -d $MAPNIK_DATA ]
then
    echo "Creating $MAPNIK_DATA directory"
    mkdir $MAPNIK_DATA
fi

# download TileLite sources
wget -c --progress=dot:mega http://bitbucket.org/springmeyer/tilelite/get/tip.zip
unzip -o tip.zip
rm tip.zip
cd $TMP/tilelite

# install tilelite using the standard python installation tools
python setup.py install # will install 'tilelite.py' in dist-packages and 'liteserv.py' in default bin directory

# copy TileLite demo application and data to 'mapnik' subfolder of DATA_FOLDER
cp -R demo $MAPNIK_DATA

# now get rid of temporary unzipped sources
rm -fr $TMP/tilelite

# Make the mapfile's path to the shapefile absolute
# because relative paths are not well supported until Mapnik 0.6.1
cd $MAPNIK_DATA
# ubuntu
sed -e "s:demo:`pwd`/demo:" -i demo/population.xml
# mac osx
#sed -e "s:demo:`pwd`/demo:" -i -f demo/population.xml

# Create startup script for TileLite Mapnik Server
cat << EOF > $BIN/mapnik_start_tilelite.sh
#!/bin/sh
liteserv.py /usr/local/share/mapnik/demo/population.xml
EOF

chmod 755 $BIN/mapnik_start_tilelite.sh


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
Exec=dash /home/user/launchassist.sh $BIN/mapnik_start_tilelite.sh
Icon=boot
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
Exec=firefox /usr/local/share/livedvd-docs/doc/mapnik_description.html
Icon=browser
Terminal=false
StartupNotify=false
EOF

cp -a /usr/share/applications/mapnik-intro.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/mapnik-intro.desktop"
