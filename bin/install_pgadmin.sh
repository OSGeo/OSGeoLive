#!/bin/sh
# Copyright (c) 2013-2022 The Open Source Geospatial Foundation and others.
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
# This script will install pgadmin4 in ubuntu

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/${USER_NAME}"
USER_DESKTOP="${USER_HOME}/Desktop"
BUILD_DIR=`pwd`

##Add pgadmin4 key

wget https://www.pgadmin.org/static/packages_pgadmin_org.pub
apt-key add packages_pgadmin_org.pub
rm packages_pgadmin_org.pub

##Add pgadmin4 repository

cp "$BUILD_DIR"/../sources.list.d/pgadmin4.list /etc/apt/sources.list.d/
apt-get -q update

apt-get install --yes pgadmin4-desktop

rm /etc/apt/sources.list.d/pgadmin4.list
apt-get -q update

##Setup pgadmin4 settings

mkdir -p "$USER_HOME/.pgadmin"
cp "$BUILD_DIR"/../app-conf/postgresql/pgadmin4.db "$USER_HOME/.pgadmin/pgadmin4.db"

cp /usr/share/applications/pgadmin4.desktop "$USER_HOME"/Desktop/

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
