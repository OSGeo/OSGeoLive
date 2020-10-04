#!/bin/sh
#################################################
#
# Purpose: Installation of openjump into ubuntu
# Authors:  Stefan Hansen <shansen[AT]lisasoft.com>
#           edso <edso[AT]users.sourceforge.net>
#
# Changes:
#  25 Jan 2011  Update script to openJUMP 1.4
#   8 Jan 2012  changes for OJ 1.5
#  12 Jun 2013  changes for OJ 1.6 live-dvd 7.0
#  14 Jun 2014  changes for OJ 1.7 live-dvd 8.0
#  20 Aug 2018  osgeolive12
#
#################################################
# Copyright (c) 2011-2014 Edgar Soldin, openjump team
# Copyright (c) 2010-2020 Open Source Geospatial Foundation (OSGeo) and others.
# Copyright (c) 2009 LISAsoft
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
##################################################
#
# About:
# =====
# This script will install openjump into Xubuntu
#
# Running:
# =======
# sudo ./install_openjump.sh [--clean,--force]

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_openjump"

## default defs, may be overwritten by online conf file below 
PKG_NAME=OpenJUMP
PKG_VERSION=1.5


# dns trouble? test if we can see it
host sourceforge.net || exit 1

## get defs from online conf file ( file vars, pkg_version ) for update convenience
URL_LIST=http://downloads.sourceforge.net/project/jump-pilot/OpenJUMP/osgeo/osgeo.conf
# download and set vars (filter out anything not setting a variable)
eval "$(wget -nv -O- "$URL_LIST" | awk '/^[a-zA-Z0-9_-]+=/')"

PKG_FOLDER="$PKG_NAME-$PKG_VERSION"
PKG_HOME="/usr/lib/$PKG_FOLDER"
PKG_DATA="/usr/local/share/$PKG_NAME"
PKG_DATA_SAMPLES="$PKG_DATA/sample_data"
PKG_DATA_SAMPLES_LINK="/usr/local/share/data/vector/$PKG_NAME"
PKG_LINK=/usr/local/bin/openjump
PKG_DESKTOP="$USER_HOME/Desktop/openjump.desktop"
PKG_SUCCESS="$PKG_HOME/.installed"

## these defs are defined by conf file above
#URL_PKG=http://downloads.sourceforge.net/project/jump-pilot/OpenJUMP_snapshots/OpenJUMP-20120108-r2597-CORE.zip
#URL_ICON=http://jump-pilot.svn.sourceforge.net/viewvc/jump-pilot/core/trunk/icon/openjump_icon3.svg
#URL_DATA=http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.4%20Tutorials/ojtutorial_general_2011_data.zip
#URL_DOC=http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.4%20Tutorials/ojtutorial_general_2011.pdf

## Setup things... ##

# check required tools are installed
if [ -f $PKG_SUCCESS ] && [ -z "$1" ] ; then
  echo "Use --force to reinstall."
  exit 1
fi

if [ ! -x "`which wget`" ] ; then
  echo "ERROR: wget is required, please install it and try again"
  exit 1
fi

# always cleanup first
(rm -rfv "$TMP" /usr/lib/$PKG_NAME-* "$PKG_DESKTOP" "$PKG_LINK" "$PKG_DATA" "$PKG_DATA_SAMPLES_LINK" "$USER_HOME/.openjump") 2>/dev/null
[ "$1" = "--clean" ] && exit

# create tmp folders
rm -rf "$TMP"
mkdir -p "$TMP"
cd "$TMP"

## get file list ##
# wget -nv "$URL_LIST" && \
#  eval $(cat $(basename "$URL_LIST")) &&\

## Install Application ##
wget -c --progress=dot:mega "$URL_PKG" && \
  unzip -q $(basename $URL_PKG) -d app && \
  mv app/$(ls -1 app | head -1) $PKG_FOLDER && rm -rf app &&\

# get icon
wget -nv "$URL_ICON" -O $PKG_FOLDER/icon.svg  && \

# post install routines, set permissions etc.
chmod 755 "$PKG_FOLDER/bin/oj_linux.sh" &&\
"$PKG_FOLDER/bin/oj_linux.sh" --post-install &&\
mv "$PKG_FOLDER" "$PKG_HOME" &&\

# create link to startup script
ln -sf $PKG_HOME/bin/oj_linux.sh /usr/bin/openjump &&\

# create desktop link
( cat >$PKG_DESKTOP <<END
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=OpenJUMP
Comment=
Categories=Application;
Exec=openjump
Icon=$PKG_HOME/icon.svg
Terminal=false
StartupNotify=false
END
) &&\

## set proper permissions to desktop link ##
chmod 644 -R "$PKG_DESKTOP" &&\
chown "$USER_NAME"."$USER_NAME" "$PKG_DESKTOP" &&\

## Sample Data ##
wget -N --progress=dot:mega "$URL_DATA" &&\
mkdir -p "$PKG_DATA/sample_data" &&\
unzip -o -j -q $(basename $URL_DATA) -x '*/.*' -d "$PKG_DATA/sample_data" 2>&1 | awk '!/excluded filename not matched/' &&\

## Documentation ##
wget -N --progress=dot:mega "$URL_DOC" &&\
cp $(basename "$URL_DOC") "$PKG_DATA/" &&\

## set proper permissions for data ##
chmod 644 -R "$PKG_DATA" &&\
chmod a+X -R "$PKG_DATA" &&\
touch $PKG_SUCCESS

# share data with the rest of the disc
mkdir -p $(dirname "$PKG_DATA_SAMPLES_LINK") &&\
ln -s "$PKG_DATA_SAMPLES" \
      "$PKG_DATA_SAMPLES_LINK"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
