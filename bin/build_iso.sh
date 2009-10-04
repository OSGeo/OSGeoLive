#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will create a bootable iso from the current running system

# Running:
# Note: Run this absolutely last, especially after doing filesystem cleanup
# =======
# sudo ./build_iso.sh
#


DIR=`dirname ${0}`
VERSION=`cat ${DIR}/../VERSION.txt`
PACKAGE_NAME="arramagong-livedvd"
ISO_NAME="${PACKAGE_NAME}-${VERSION}"
WORKDIR="/tmp/remastersys"
TMP="${WORKDIR}/ISOTMP"
LOGS="/var/log/arramagong/remastersys.conf"
DOCS_SRC="/usr/local/share/livedvd-docs"

#Install remastersys.sh add directories it expects
mkdir -p $TMP
mkdir -p $WORKDIR/ISOTMP/casper
mkdir -p $WORKDIR/ISOTMP/preseed
mkdir -p $WORKDIR/dummysys/dev
mkdir -p $WORKDIR/dummysys/etc
mkdir -p $WORKDIR/dummysys/proc
mkdir -p $WORKDIR/dummysys/tmp
mkdir -p $WORKDIR/dummysys/sys
mkdir -p $WORKDIR/dummysys/mnt
mkdir -p $WORKDIR/dummysys/media/cdrom
mkdir -p $WORKDIR/dummysys/var
chmod ug+rwx,o+rwt $WORKDIR/dummysys/tmp

wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/arramagong_2/sources.list.d/remastersys.list \
     --output-document=/etc/apt/sources.list.d/remastersys.list

# apt-get update
apt-get update

# no !@#$%!%#@ GPG key
apt-get --assume-yes --force-yes install remastersys

#Configure
#ie set exclude folders in /etc/remastersys.conf
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/arramagong_2/app-data/remastersys.conf \
     --output-document=$LOGS
cp $LOGS /etc/remastersys.conf

#Add Windows and Mac installers by copying files into ISOTMP folder
./load_win_installers.sh
./load_mac_installers.sh

# Copy documentation
cp -pr ${DOCS_SRC} ${TMP}

#Update the file search index
updatedb

#quick name check
echo "Now creating ${ISO_NAME}.iso"

#Create iso, only uncomment once it's working
remastersys backup ${ISO_NAME}.iso

