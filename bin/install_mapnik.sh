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

# will fetch Mapnik 0.5.1 on Ubuntu 9.04
apt-get install --yes python-mapnik


# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp"
DATA_FOLDER="/usr/local/share"
MAPNIK_DATA=$DATA_FOLDER/mapnik
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
BIN="/usr/bin"

cd $TMP

## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

if [ ! -d $MAPNIK_DATA ]
then
    echo "Create $MAPNIK_DATA directory"
    mkdir $MAPNIK_DATA
fi

# download TileLite sources
wget -c http://bitbucket.org/springmeyer/tilelite/get/tip.zip
unzip -o tip.zip
rm tip.zip
cd $TMP/tilelite


# using the standard python installation tools
python setup.py install # will install 'tilelite.py' in site-packages and 'liteserv.py' in default bin directory

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

# Create the index page
cat <<EOF > $MAPNIK_DATA/index.html
<html>
<title>Mapnik 0.5.1</title>
<body>

<div id="about">

<h1>About Mapnik</h1>

<p>Mapnik</p>

</div>
</body>
</html>
EOF

# Demo Tiles app using OpenLayers
cat << EOF > $BIN/mapnik_start_tilelite.sh
#!/bin/sh
bash -c "firefox -new-tab /usr/local/share/mapnik/demo/openlayers.html"
liteserv.py /usr/local/share/mapnik/demo/population.xml
EOF

chmod 755 $BIN/mapnik_start_tilelite.sh


## TileLite start icon
cat << EOF > /usr/share/applications/mapnik-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Mapnik Demo
Comment=Mapnik Demo using TileLite Server
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/mapnik_start_tilelite.sh
Icon=
Terminal=False
EOF

cp -a /usr/share/applications/mapnik-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/mapnik-start.desktop"

# Demo Tiles app using OpenLayers
cat << EOF > /usr/share/applications/mapnik-intro.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapnik Intro
Comment=Mapnik Intro
Categories=Application;Education;Geography;Graphics;
Exec=firefox /usr/local/share/mapnik/index.html
Icon=
Terminal=false
Categories=Education;Geography;Graphics;
EOF

cp -a /usr/share/applications/mapnik-intro.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/mapnik-intro.desktop"

