#!/bin/sh
#############################################################################
#
# Purpose: This script will install actinia_core (REST API for GRASS GIS 7)
#
# References:
#          - Code: https://github.com/mundialis/actinia_core/
#          - Publication: https://doi.org/10.5281/zenodo.2631917
#          - Tutorial: https://actinia.mundialis.de/tutorial/
#
# Requirements: GRASS GIS 7, Python, redis
#
# actinia URL after installation: http://localhost:8088/api/v1/version
#
#################################################################################
# Copyright (c) 2018-2019 Sören Gebbert and mundialis GmbH & Co. KG, Bonn.
# Copyright (c) 2020 The Open Source Geospatial Foundation and others.
#
# Installer script author: Markus Neteler <neteler mundialis.de>
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
#################################################################################

# About:
# =====
# This script will install actinia_core with actinia_statistic_plugin
#
# Script inspired by https://github.com/mundialis/actinia_core/blob/master/docker/actinia-core/Dockerfile
#
# This does not attempt to install GRASS GIS, that is done in install_grass.sh.
#################################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BIN="/usr/local/bin"
ACTINIA_HOME="/opt/actinia_core"
ACTINIA_CONF="/etc/actinia"

mkdir -p "$ACTINIA_HOME"
mkdir -p "$ACTINIA_CONF"

# Create the database directories
mkdir -p "$ACTINIA_HOME"/grassdb
mkdir -p "$ACTINIA_HOME"/resources
mkdir -p "$ACTINIA_HOME"/workspace/tmp
mkdir -p "$ACTINIA_HOME"/workspace/temp_db
mkdir -p "$ACTINIA_HOME"/workspace/actinia
mkdir -p "$ACTINIA_HOME"/workspace/download_cache
mkdir -p "$ACTINIA_HOME"/userdata

apt-get -q update
apt-get --assume-yes install python3-actinia-core python3-actinia-statistic-plugin redis-server gunicorn

# Add default password for redis
sed -i -e 's|# requirepass foobared|requirepass pass|' \
    /etc/redis/redis.conf

# copy actinia configuration
cp "$BUILD_DIR/../app-conf/actinia/actinia.cfg" "$ACTINIA_CONF/actinia.cfg"

# link grassdb to grass demo dataset
ln -s "$USER_HOME"/grassdata/nc_basic_spm_grass7 "$ACTINIA_HOME"/grassdb

# create some grass locations
grass -text -e -c 'EPSG:25832' "$ACTINIA_HOME"/grassdb/utm32n
grass -text -e -c 'EPSG:4326' "$ACTINIA_HOME"/grassdb/latlong
# grass -text -e -c 'EPSG:3358' "$ACTINIA_HOME"/grassdb/nc_basic_spm_grass7

# Install actinia-core plugins
# apt-get --assume-yes install python3-actinia-statistic python3-actinia-satellite

# actinia launcher
mkdir -p "$BIN"
cat << EOF > "$BIN/actinia_start.sh"
#!/bin/bash
DEFAULT_CONFIG_PATH=/etc/actinia/actinia.cfg gunicorn3 -b 0.0.0.0:8088 -w 1 actinia_core.main:flask_app
EOF

chmod 755 $BIN/actinia_start.sh
chmod -R 777 "$ACTINIA_HOME"

echo 'Downloading actinia logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/actinia.png \
   "https://github.com/mundialis/actinia_core/raw/master/docs/actinia_logo.png"

## Create Desktop Shortcut for starting Actinia Server in shell
cat << EOF > /usr/share/applications/actinia-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Actinia
Comment=Actinia for OSGeoLive
Categories=Application;Geography;Geoscience;Education;
Exec=/usr/local/bin/actinia_start.sh
Icon=actinia
Terminal=true
StartupNotify=false
EOF

cp -a /usr/share/applications/actinia-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/actinia-start.desktop"

# DONE.
# actinia is now reachable at http://localhost:8088/api/v1/version

# test
# curl -u actinia-gdi:actinia-gdi 'http://localhost:8088/api/v1/version'

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

