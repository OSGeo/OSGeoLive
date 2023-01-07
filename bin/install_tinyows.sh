#!/bin/sh
# Copyright (c) 2009-2023 The Open Source Geospatial Foundation and others.
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

# About:
# =====
# This script will install tinyows in ubuntu

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_tinyows
if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi

#Download sample data and add to PostgreSQL
cd "$TMP_DIR"
wget -c --tries=3 --progress=dot:mega \
   "https://github.com/MapServer/tinyows/raw/main/demo/france.dbf"
wget -c --tries=3 --progress=dot:mega \
   "https://github.com/MapServer/tinyows/raw/main/demo/france.shp"
wget -c --tries=3 --progress=dot:mega \
   "https://github.com/MapServer/tinyows/raw/main/demo/france.shx"

sudo -u $USER_NAME createdb tinyows_demo
sudo -u $USER_NAME psql tinyows_demo -c 'create extension postgis;'
sudo -u $USER_NAME shp2pgsql -s 27582 -I -W latin1 ./france.shp france > france.sql
sudo -u $USER_NAME psql tinyows_demo < france.sql
rm -rf france.*

#Install packages
apt-get -q update
apt-get --assume-yes install tinyows

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

#Setup sample config
### HB: put into /usr/local/share/tinyows/ and not /etc?
cd "$BUILD_DIR"
cp ../app-conf/tinyows/tinyows.xml /etc/

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
