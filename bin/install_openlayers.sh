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
# This script will install OpenLayers 3.0.0
#
# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/openLayers/

./diskspace_probe.sh "`basename $0`" begin
BIN_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_openlayers"
OL_VERSION="v3.0.0"
GIT_DIR="$TMP_DIR/openlayers-$OL_VERSION"
GIT_OL3_URL="https://github.com/openlayers/ol3.git"
BUILD_DIR="build/hosted/HEAD"
WWW_DIR=/var/www/html/openlayers

#
# Make certain of some prerequisites
#
apt-get install --yes python-pip python-pystache node npm 

#
# Clone repository, checkout the latest stable tag and install dependencies
#
echo "\nCreating temporary directory $TMP_DIR..."
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
echo "\nFetching project..."
if [ ! -d "$GIT_DIR" ] ; then
    # Clone project and checkout the stable tag
    echo "\nClonning project from $GIT_OL3_URL..."
    git clone "$GIT_OL3_URL" "$GIT_DIR" 
    echo "\nChanging to tag $OL_VERSION..."
    cd "$GIT_DIR"
    git checkout "$OL_VERSION"

    # Install dependencies for build process
    echo "\nInstalling npm dependencies..."
    npm install
    echo "\nInstalling other dependencies..."
    pip install -r requirements.txt
    cd -
else
    echo "... OpenLayers-$OL_VERSION already cloned\n"
fi

cd "$GIT_DIR"

#
# Build OpenLayers and examples
#
echo "\nBuilding OpenLayers and examples..."
if [ ! -d "$GIT_DIR/build" ] ; then
    # NOTE: The 'host-examples' also includes the 'build' target
    ./build.py host-examples
else 
    echo "... previous built for OpenLayers-$OL_VERSION exists. Remove $GIT_DIR/build to create a fresh built.\n"
fi

#
# Build API docs
#
echo "\nBuilding API docs..."
if [ ! -d "$GIT_DIR/$BUILD_DIR/apidoc" ] ; then
    ./build.py apidoc
else 
    echo "... previous version of API docs for OpenLayers-$OL_VERSION exists. Remove $GIT_DIR/build/apidocs to create a fresh built.\n"
fi

#
# Generate index page
#
cd "$GIT_DIR/$BUILD_DIR"

cat << EOF > "index.html"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
<body>
<h2>OpenLayers $OL_VERSION</h2>
<ul>
build/hosted/HEAD/apidoc
<li><a href="build/hosted/HEAD/apidoc/">API Docs</a></li>
<li><a href="build/hosted/HEAD/examples/">Examples</a></li>
<li><a href="http://openlayers.org/">OpenLayers.org website</a></li>
</ul>
</body>
</html>
EOF

#
# Copy files to apache dir
#
mkdir -p "$WWW_DIR"
cp -R "$GIT_DIR/$BUILD_DIR" "$WWW_DIR"
chmod -R uga+r "$WWW_DIR"

#
# Launch script and icon for OpenLayers to take you to a documentation 
# page and examples listing
#
cp "$GIT_DIR/$BUILD_DIR/resources/logo.png" /usr/share/pixmaps/openlayers.png

if [ ! -e /usr/share/applications/openlayers.desktop ] ; then
   cat << EOF > /usr/share/applications/openlayers.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=OpenLayers
Comment=Sample constructions
Categories=Application;Internet;
Exec=firefox http://localhost/openlayers/ http://localhost/en/quickstart/openlayers_quickstart.html
Icon=openlayers
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/openlayers.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/openlayers.desktop"

#
# Add a symbolic link into the ipython notebook extension directory
# TODO - Necessary ???
#
mkdir -p "$USER_HOME"/.ipython/nbextensions/
ln -s /var/www/html/openlayers/ "$USER_HOME"/.ipython/nbextensions/

####
"$BIN_DIR"/diskspace_probe.sh "`basename $0`" end
