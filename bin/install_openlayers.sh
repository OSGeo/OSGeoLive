#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install OpenLayers 2.13
#
# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/openLayers/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR="/tmp/build_openlayers"
OL_VERSION="2.13.1"


#Install naturaldocs if not installed yet
hash naturaldocs 2>/dev/null
if [ $? -ne 0 ] ; then
    echo "Installing naturaldocs..."
    apt-get --assume-yes install naturaldocs 
    OL_APT_REMOVE=naturaldocs
fi

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

GIT_DIR="openlayers-$OL_VERSION"

echo "\nFetching git clone..."
if [ ! -d "$GIT_DIR" ] ; then
    git clone https://github.com/openlayers/openlayers.git "$GIT_DIR" 
else
    echo "... openLayers-$OL_VERSION already cloned"
fi

cd "$GIT_DIR"

echo "\nBuilding examples index"
if [ ! -s examples/example-list.js ] ; then
    cd tools
    ./exampleparser.py
    cd ..
else
    echo "... example index already built"
fi

ln -sf example-list.html examples/index.html
echo "Done."

echo "\nBuilding full uncompressed OpenLayers.js"
cd build
./buildUncompressed.py
cd ..
ln -sf build/OpenLayers.js

echo "\nBuilding API docs..."
if [ ! -d doc ] ; then
    mkdir doc
fi
echo `pwd`
naturaldocs -i lib/ -o HTML doc/ -p doc_config/ -s Default OL

#Index Page
cat << EOF > "index.html"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
<body>
<h2>OpenLayers $OL_VERSION</h2>
<ul>
<li><a href="doc/">API Docs</a></li>
<li><a href="examples/">Examples</a></li>
<li><a href="http://openlayers.org/">OpenLayers.org website</a></li>
</ul>
</body>
</html>
EOF

cd "$TMP_DIR"

mkdir -p /var/www/html/openlayers
cp -R "$GIT_DIR"/* /var/www/html/openlayers/
chmod -R uga+r /var/www/html/openlayers

#Remove packages
if [ -n "$OL_APT_REMOVE" ] ; then
    echo "Removing naturaldocs..."
    apt-get --assume-yes remove $OL_APT_REMOVE
fi

#TODO: Launch script and icon for OpenLayers to take you to a documentation page and examples listing
#Add Launch icon to desktop
cp "$BUILD_DIR"/../doc/images/project_logos/logo-OpenLayers.png \
    /usr/share/pixmaps/openlayers.png

if [ ! -e /usr/share/applications/openlayers.desktop ] ; then
   cat << EOF > /usr/share/applications/openlayers.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenLayers
Comment=Sample constructions
Categories=Application;Internet;
Exec=firefox http://localhost/openlayers/examples/ http://localhost/en/quickstart/openlayers_quickstart.html
Icon=openlayers
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/openlayers.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/openlayers.desktop"


# add a symbolic link into the ipython notebook extension directory
mkdir -p "$USER_HOME"/.ipython/nbextensions/
ln -s /var/www/html/openlayers/ "$USER_HOME"/.ipython/nbextensions/

#TODO: Create local example that uses data from the many wms/wfs sources on the live disc


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
