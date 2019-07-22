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
# actinia URL after installation: http://localhost:8080/api/v1/version
#
#################################################################################
# Copyright (c) 2018-2019 Sören Gebbert and mundialis GmbH & Co. KG, Bonn.
# Copyright (c) 2019 The Open Source Geospatial Foundation and others.
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

TMP_DIR=/tmp/build_actinia
mkdir "$TMP_DIR"

apt-get -q update
apt-get --assume-yes install python3-actinia-core redis-server

# get source code
# https://github.com/mundialis/actinia_core
cd "$TMP_DIR"
git clone --single-branch https://github.com/mundialis/actinia_core.git
cd actinia_core/

# from https://github.com/mundialis/actinia_core/blob/master/docker/actinia-core-prod/Dockerfile
# generate actinia.cfg
# this overrides global settings in src/actinia_core/resources/common/config.py
cat docker/actinia-core-prod/actinia.cfg | \
    sed 's+/usr/local/bin/grass+/usr/bin/grass+g' | \
    sed 's+/actinia_core+/opt/actinia_core+g' | \
    sed 's+/usr/local/grass7+/usr/lib/grass76+g' | \
    sed 's+redis_server_url =  redis+redis_server_url = localhost+g' | \
    sed 's+redis_queue_server_url = redis+redis_queue_server_url = localhost+g' | \
    sed 's+token_signing_key_changeme+token_my_secret_osgeolive+g' > actinia.cfg

# generate start.sh
cat docker/actinia-core-prod/start.sh | sed 's+/usr/local/bin/grass+/usr/bin/grass+g' | sed 's+/actinia_core+/opt/actinia_core+g' | sed 's+/usr/local/grass7+/usr/lib/grass76+g' > start.sh

# Copy actinia config file and start script
mkdir -p /etc/default/
mkdir -p /src
mkdir -p /opt/actinia_core

cp -f actinia.cfg /etc/default/actinia
cp -f start.sh /src/start.sh

# prepare some sample data
mkdir -p /opt/actinia_core/grassdb/
(cd /opt/actinia_core/grassdb/ && wget -c https://grass.osgeo.org/sampledata/north_carolina/nc_basic_spm_grass7.zip && unzip nc_basic_spm_grass7.zip && rm -f nc_basic_spm_grass7.zip && mv nc_basic_spm_grass7 nc_spm_08)
# we now have /opt/actinia_core/grassdb/nc_spm_08/

# install actinia_core
python setup.py install

# Install actinia-core plugins
cd "$TMP_DIR"
git config --global http.sslVerify false
git clone --single-branch https://github.com/mundialis/actinia_statistic_plugin.git actinia_statistic_plugin
cd actinia_statistic_plugin/
pip install -r requirements.txt
# install actinia_statistic_plugin
python setup.py install

# Create the database directories
mkdir -p /opt/actinia_core/grassdb && \
  mkdir -p /opt/actinia_core/resources && \
  mkdir -p /opt/actinia_core/workspace/tmp && \
  mkdir -p /opt/actinia_core/workspace/temp_db && \
  mkdir -p /opt/actinia_core/workspace/actinia && \
  mkdir -p /opt/actinia_core/workspace/download_cache && \
  mkdir -p /opt/actinia_core/userdata

# launch redis
redis-server &

# launch actinia
python -m actinia_core.main &

# add/change users besides the existing demo users TODO

# cleanup
rm -rf "$TMP_DIR"

# DONE.
# actinia is now reachable at http://localhost:8080/api/v1/version

# test
# curl -u actinia-gdi:actinia-gdi 'http://localhost:8080/api/v1/version'

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

