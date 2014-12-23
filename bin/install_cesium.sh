#!/bin/sh
# Author: Balasubramaniam Natarajan <bala150985 gmail> / Brian M Hamlin <dbb>
# Copyright (c) 2014 The Open Source Geospatial Foundation.
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
#
# script to install Cesium
#    homepage: http://cesiumjs.org/
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR='/tmp/build_cesium'
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p $BUILD_DIR
cd $BUILD_DIR
wget -c http://cesiumjs.org/releases/Cesium-1.4.zip

#The next four lines will make sure unzip program is intalled
IsUnZipPresent=`/usr/bin/which unzip | /usr/bin/wc -l`
if [ $IsUnZipPresent -eq 0 ]; then
  apt-get install unzip
fi

if [ -d $BUILD_DIR/cesium ]; then
  rm -rf $BUILD_DIR/cesium
fi

mkdir -p $BUILD_DIR/cesium
unzip $BUILD_DIR/Cesium-1.4.zip -d /tmp/build_cesium/cesium/

if [ -d /var/www/html/cesium ]; then
  rm -rf /var/www/html/cesium
fi

cp -rf $BUILD_DIR/cesium /var/www/html/

chgrp www-data -R /var/www/html/cesium

## TODO make a desktop launcher
#firefox -new-window http://localhost/cesium/Apps/HelloWorld.html -new-tab http://localhost/cesium/ &

## Cleanup

rm -rf $BUILD_DIR
#rm -rf /var/www/html/cesium/Build

####
./diskspace_probe.sh "`basename $0`" end
