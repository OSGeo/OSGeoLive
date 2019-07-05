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
# actinia URL: http://localhost:8080/api/v1/version
#
# Script author: Markus Neteler <neteler mundialis.de>
#
#############################################################################
# Copyright (c) 2019 Sören Gebbert and mundialis GmbH & Co. KG, Bonn.
#
# Licensed under the GNU GPL version >= 3
#
# This program is free software under the GNU General Public License (>=v3).
# Read the file COPYING that comes with actinia_core for details.
#
#############################################################################
#
# Script inspired by https://github.com/mundialis/actinia_core/blob/master/docker/actinia-core/Dockerfile


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

apt-get --quiet update

# get source code
# https://github.com/mundialis/actinia_core
cd "$TMP_DIR"
git clone --single-branch https://github.com/mundialis/actinia_core.git
cd actinia_core/

# generate virtual env for Python3
apt -y install virtualenv
apt -y install python3-dev
virtualenv -p python3 venv
. venv/bin/activate

# install redis
apt -y install redis-server

# install actinia_core Python requirements
pip install -r requirements.txt 

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
(cd /opt/actinia_core/grassdb/ ; wget https://grass.osgeo.org/sampledata/north_carolina/nc_basic_spm_grass7.zip ; unzip nc_basic_spm_grass7.zip ; rm -f nc_basic_spm_grass7.zip ; mv nc_basic_spm_grass7 nc_spm_08)
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

