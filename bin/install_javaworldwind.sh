#!/bin/sh
#############################################################################
#
# Purpose: This script will install Java World Wind
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
BUILD_DIR='/tmp/build_WW'
INST_DIR=WorldWindJava
UNZIP_DIR=$BUILD_DIR/$INST_DIR

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

#Temp dir creation and download
echo "\nCreating temporary directory $BUILD_DIR..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

echo "\nDownloading Nasa Java World Wind..."
wget -c http://builds.worldwind.arc.nasa.gov/worldwind-releases/2.0/builds/worldwind-2.0.0.zip



echo "\nInstalling Nasa World Wind Java..."
IsUnZipPresent=`/usr/bin/which unzip | /usr/bin/wc -l`
if [ $IsUnZipPresent -eq 0 ]; then
  apt-get install unzip
fi


#Install icedtea for the web start
echo "\nInstalling Java Web Start..."
if [  ! -e /usr/lib/jvm/java-7-openjdk-i386/jre/bin/itweb-settings ]; then
apt-get install icedtea-7-plugin
fi



if [ -d $UNZIP_DIR ]; then
  rm -rf $UNZIP_DIR
fi

mkdir -p $UNZIP_DIR
unzip $BUILD_DIR/worldwind-2.0.0.zip -d $UNZIP_DIR/

#removing doc,gdal, sample data to save space
rm -rf $UNZIP_DIR/lib-external/gdal
rm -rf $UNZIP_DIR/doc
rm -rf $UNZIP_DIR/testData



#creating an executable of a sample
if [ ! -e $INST_DIR/runSample.sh ]; then
  echo 'cd /usr/local/share/WorldWindJava/&&./run-demo.bash gov.nasa.worldwindx.examples.ApplicationTemplate&firefox http://localhost/osgeolive/en/quickstart/wwj_quickstart.html'>> $INST_DIR/runSample.sh
fi
chmod +x $INST_DIR/runSample.sh
chmod +x $INST_DIR/run-demo.bash

cp -rf $UNZIP_DIR /usr/local/share/



# Install desktop icon
if [ ! -e "/usr/share/pixmaps/nasa_jww.png" ] ; then
    wget -c --progress=dot:mega \
        "http://www.nasa.gov/sites/default/files/images/nasaLogo-570x450.png" \
        -O /usr/share/pixmaps/nasa_jww.png
fi


#Generating launcher
echo "\nGenerating launcher..."

if [ ! -e /usr/share/applications/nasa_jww.desktop ] ; then
   cat << EOF > /usr/share/applications/nasa_jww.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=World Wind Java
Comment=Nasa Go World Wind Example
Categories=Application;Internet;
Exec=sh /usr/local/share/WorldWindJava/runSample.sh
Icon=nasa_jww
Terminal=false
StartupNotify=false
EOF
fi

#Desktop link
cp /usr/share/applications/nasa_jww.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/nasa_jww.desktop"
chmod +x "$USER_HOME/Desktop/nasa_jww.desktop"

## Cleanup
echo "\nCleanup..."
rm -rf $BUILD_DIR

####
"$BIN_DIR"/diskspace_probe.sh "`basename $0`" end

