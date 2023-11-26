#!/bin/sh
#############################################################################
#
# Purpose: This script will install actinia_core (REST API for GRASS GIS 8)
#
# References:
#          - Code: https://github.com/actinia-org/actinia-gdi
#          - Publication: https://doi.org/10.5281/zenodo.2631917
#          - Tutorial: https://actinia.mundialis.de/tutorial/
#
# Requirements: GRASS GIS 8, Python, redis
#
# actinia URL after installation: http://localhost:8088/api/v3/version
#
#################################################################################
# Copyright (c) 2018-2019 Sören Gebbert and mundialis GmbH & Co. KG, Bonn.
# Copyright (c) 2020-2023 The Open Source Geospatial Foundation and others.
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
# This script will install actinia-core with selected actinia plugins
#
# Script inspired by https://github.com/actinia-org/actinia-core/blob/main/docker/actinia-core-alpine/Dockerfile
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
# see https://github.com/actinia-org/actinia-docker/blob/main/actinia-alpine/actinia.cfg
ACTINIA_CONF="/etc/default/"

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
apt-get --assume-yes install redis-server

# install actinia in python virtualenv
apt-get install -y python3-venv
python3 -m venv $ACTINIA_HOME/venv-actinia
# source $USER_HOME/venv-actinia/bin/activate

# install dependencies into venv
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install boto3 colorlog flask_cors flask_httpauth flask_restful_swagger_2 \
     google-cloud google-cloud-bigquery google-cloud-storage gunicorn matplotlib \
     passlib pyproj pystac python-dateutil PyJWT python-json-logger python-keycloak \
     python-magic redis requests rq shapely

# latest actinia-core installation
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install actinia-core

# actinia API
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install https://github.com/actinia-org/actinia-api/releases/download/3.4.0/actinia_api-3.4.0-py3-none-any.whl

# actinia plugins
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install https://github.com/actinia-org/actinia-statistic-plugin/releases/download/0.2.1/actinia_statistic_plugin-0.2.1-py2.py3-none-any.whl
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install https://github.com/actinia-org/actinia-satellite-plugin/releases/download/0.1.0/actinia_satellite_plugin-0.1.0-py2.py3-none-any.whl
$ACTINIA_HOME/venv-actinia/bin/python3 -m pip install https://github.com/actinia-org/actinia-module-plugin/releases/download/2.5.0/actinia_module_plugin.wsgi-2.5.0-py2.py3-none-any.whl

# left out in OSGeolive
## Add default password for redis
#sed -i -e 's|# requirepass foobared|requirepass pass|' \
#    /etc/redis/redis.conf

# copy actinia configuration
cp "$BUILD_DIR/../app-conf/actinia/actinia.cfg" "$ACTINIA_CONF/actinia.cfg"

# link grassdb to grass demo dataset
ln -s "$USER_HOME"/grassdata/nc_basic_spm_grass7 "$ACTINIA_HOME"/grassdb

# create some grass locations
grass --text -e -c 'EPSG:25832' "$ACTINIA_HOME"/grassdb/utm32n
grass --text -e -c 'EPSG:4326' "$ACTINIA_HOME"/grassdb/latlong
# grass --text -e -c 'EPSG:3358' "$ACTINIA_HOME"/grassdb/nc_basic_spm_grass7

# actinia launcher
mkdir -p "$BIN"
cat << EOF > "$BIN/actinia_start.sh"
#!/bin/bash
set -e
source /opt/actinia_core/venv-actinia/bin/activate
# start redis server
redis-server &
sleep 1
redis-cli ping

export DEFAULT_CONFIG_PATH=/etc/actinia/actinia.cfg

actinia-user create -u actinia-gdi -w actinia-gdi -r superadmin -g superadmin -c 100000000000 -n 1000 -t 31536000

gunicorn3 -b 0.0.0.0:8088 -w 1 actinia_core.main:flask_app
EOF

chmod 755 $BIN/actinia_start.sh
chmod -R 777 "$ACTINIA_HOME"

echo 'Downloading actinia logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/actinia.png \
   "https://github.com/actinia-org/actinia-core/raw/main/docs/docs/actinia_logo.png"

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
# actinia is now reachable at http://localhost:8088/api/v3/version
#
# apt-get install links -y
# links http://localhost:8088/api/v3/version

# test
# apt-get install curl -y
# curl -u actinia-gdi:actinia-gdi 'http://localhost:8088/api/v3/version'

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
