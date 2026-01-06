#!/bin/sh
#############################################################################
#
# Purpose: This script will install actinia_core (REST API for GRASS GIS 8)
#
# References:
#          - Code: https://github.com/actinia-org/actinia-core
#          - Publication: https://doi.org/10.5281/zenodo.2631917
#          - Tutorial: https://actinia.mundialis.de/tutorial/
#
# Requirements: Docker Compose
#
# actinia URL after installation: http://localhost:8088/api/v3/version
#
#################################################################################
# Copyright (c) 2018-2019 Soeren Gebbert and mundialis GmbH & Co. KG, Bonn.
# Copyright (c) 2020-2026 The Open Source Geospatial Foundation and others.
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
ACTINIA_HOME="/opt/actinia"
mkdir -p "$ACTINIA_HOME"
cd "$ACTINIA_HOME"
git clone https://github.com/actinia-org/actinia-docker.git
cd actinia-docker
git fetch origin 2.13.0
git checkout 2.13.0
chmod -R 777 "$ACTINIA_HOME"

docker pull mundialis/actinia:2.13.0
docker pull valkey/valkey:9.0-alpine

echo 'Downloading actinia logo ...'
mkdir -p /usr/local/share/icons/
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
Path=/opt/actinia/actinia-docker
Exec=docker compose -d up && firefox http://127.0.0.1:8088/api/v3/version http://localhost/osgeolive/en/overview/actinia_overview.html
Icon=actinia
Terminal=true
StartupNotify=false
EOF

cat << EOF > /usr/share/applications/actinia-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Actinia
Comment=Actinia for OSGeoLive
Categories=Application;Geography;Geoscience;Education;
Path=/opt/actinia/actinia-docker
Exec=docker compose down
Icon=actinia
Terminal=true
StartupNotify=false
EOF

cp -a /usr/share/applications/actinia-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/actinia-start.desktop"
cp -a /usr/share/applications/actinia-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/actinia-stop.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
