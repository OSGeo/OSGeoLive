#!/bin/sh
#############################################################################
#
# Purpose: This script will install pygeoapi
#
#############################################################################
# Copyright (c) 2020-2023 The Open Source Geospatial Foundation and others.
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
####
BUILD_DIR=`pwd`

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BIN="/usr/local/bin"
PYGEOAPI_DIR="/usr/local/share/pygeoapi"
PYGEOAPI_CONFIG="$PYGEOAPI_DIR/pygeoapi-config.yml"
PYGEOAPI_OPENAPI="$PYGEOAPI_DIR/pygeoapi-openapi.yml"

mkdir -p "$PYGEOAPI_DIR"

echo 'Installing pygeoapi ...'

apt-get install --yes python3-pygeoapi

# copy pygeoapi configuration
cp "$BUILD_DIR/../app-conf/pygeoapi/pygeoapi-config.yml" "$PYGEOAPI_CONFIG"
cp "$BUILD_DIR/../app-conf/pygeoapi/ne_110m_lakes.geojson" "$PYGEOAPI_DIR/ne_110m_lakes.geojson"

# generate OpenAPI document
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

echo 'Downloading pygeoapi logo ...'
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/pygeoapi.png \
      "https://github.com/geopython/pygeoapi.io/raw/master/docs/img/pygeoapi-icon.png"

echo 'Creating Scripts/Links ...'
mkdir -p "$BIN"
cat << EOF > "$BIN/pygeoapi_start.sh"
#!/bin/sh
export PYGEOAPI_CONFIG=$PYGEOAPI_CONFIG
export PYGEOAPI_OPENAPI=$PYGEOAPI_OPENAPI
pygeoapi serve
EOF

chmod 755 $BIN/pygeoapi_start.sh

echo 'Installing desktop launcher ...'

cat << EOF > /usr/share/applications/pygeoapi-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start pygeoapi
Comment=pygeoapi OGC API server
Exec=qterminal -e pygeoapi_start.sh
Icon=pygeoapi
Terminal=false
StartupNotify=false
Categories=Application;Education;Geography
EOF

cp /usr/share/applications/pygeoapi-start.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/pygeoapi-start.desktop"

cat << EOF > /usr/share/applications/pygeoapi-intro.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=pygeoapi Introduction
Comment=pygeoapi OGC API server
Exec=firefox http://localhost:5000/ http://localhost/osgeolive/en/quickstart/pygeoapi_quickstart.html
Icon=pygeoapi
Terminal=false
StartupNotify=false
Categories=Application;Education;Geography
EOF

cp /usr/share/applications/pygeoapi-intro.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/pygeoapi-intro.desktop"

####
./diskspace_probe.sh "`basename $0`" end
