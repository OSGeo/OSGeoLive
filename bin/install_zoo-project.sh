#!/bin/sh
# Copyright (c) 2010-2026 The Open Source Geospatial Foundation and others.
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
# This script will install ZOO Project through docker

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

docker pull zooproject/zoo-project:latest
# apt-get --assume-yes install zoo-kernel zoo-service-ogr \
# 	zoo-service-status zoo-service-otb zoo-service-openapi zoo-api

docker run --name zoo -d -p 85:80 zooproject/zoo-project:latest
docker stop zoo

# Get ZOO-Project icon
wget --progress=dot:mega \
  -O /usr/share/icons/zoo-icon.png \
  "http://download.osgeo.org/livedvd/data/zoo/zoo-icon.png"

# Add desktop file
cat << EOF > /usr/share/applications/zoo-project.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=ZOO Project
Comment=ZOO Project Demo
Categories=Application;Education;Geography;
Exec=docker start zoo && firefox http://localhost:85/zoo/ogc-api/ http://localhost/osgeolive/en/overview/zoo-project_overview.html
Icon=/usr/share/icons/zoo-icon.png
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/zoo-project.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/zoo-project.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
