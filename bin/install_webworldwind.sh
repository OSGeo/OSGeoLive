#!/bin/sh
#############################################################################
#
# Purpose: This script will install Web World Wind
# NASA OPEN SOURCE AGREEMENT VERSION 1.3
#
#############################################################################
# Copyright (c) 2009-2015 Open Source Geospatial Foundation (OSGeo)
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
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#############################################################################

./diskspace_probe.sh "`basename $0`" begin


# Defining directories
BIN_DIR=`pwd`
BUILD_DIR='/tmp/build_WebWorldWind'
WEB_DIR=WebWorldWind
UNZIP_DIR=$BUILD_DIR/$WEB_DIR

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


#Temp dir creation and download
echo "\nCreating temporary directory $BUILD_DIR..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR
echo "\nDownloading Nasa Web World Wind..."
wget -c http://worldwindserver.net/webworldwind/current/WebWorldWind.zip

echo "\nInstalling Web World Wind..."
IsUnZipPresent=`/usr/bin/which unzip | /usr/bin/wc -l`
if [ $IsUnZipPresent -eq 0 ]; then
  apt-get install unzip
fi

if [ -d $UNZIP_DIR ]; then
  rm -rf $UNZIP_DIR
fi

mkdir -p $UNZIP_DIR
unzip $BUILD_DIR/WebWorldWind.zip -d $UNZIP_DIR/

if [ -d /var/www/html/WebWorldWind ]; then
  rm -rf /var/www/html/WebWorldWind
fi

cp -rf $UNZIP_DIR /var/www/html/
chgrp www-data -R /var/www/html/$WEB_DIR


# Install desktop icon
if [ ! -e "/usr/share/pixmaps/nasa_www.png" ] ; then
    wget -c --progress=dot:mega \
        "http://www.nasa.gov/sites/default/files/images/nasaLogo-570x450.png" \
        -O /usr/share/pixmaps/nasa_www.png
fi


#Generating launcher
echo "\nGenerating launcher..."

if [ ! -e /usr/share/applications/nasa_www.desktop ] ; then
   cat << EOF > /usr/share/applications/nasa_www.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Nasa Web World Wind
Comment=Web World Wind Examples
Categories=Application;Internet;
Exec=firefox http://localhost/WebWorldWind/examples/BasicExample.html http://localhost/WebWorldWind/ http://localhost/osgeolive/en/quickstart/www_quickstart.html
Icon=nasa_www
Terminal=false
StartupNotify=false
EOF
fi

#Desktop link
cp /usr/share/applications/nasa_www.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/nasa_www.desktop"
chmod +x "$USER_HOME/Desktop/nasa_www.desktop"

## Cleanup
echo "\nCleanup..."
rm -rf $BUILD_DIR
####
"$BIN_DIR"/diskspace_probe.sh "`basename $0`" end
