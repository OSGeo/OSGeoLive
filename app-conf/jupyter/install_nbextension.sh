#!/bin/sh
# install_nbextension.sh
#############################################################################
#
# Purpose: This script will install CesiumWidgets
# Author: Massimo Di Stefano on 07/12/09
#
#############################################################################
# Copyright (c) 2010-2018 Open Source Geospatial Foundation (OSGeo)
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
#############################################################################

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"

APP_DATA_DIR="$BUILD_DIR/../app-data/notebooks"
SHARED_FOLDER="/usr/local/share/jupyter"

# install cesiumextension
apt-get install --yes python-czml python-pygeoif

git clone https://github.com/OSGeo-live/CesiumWidget
cd CesiumWidget
python setup.py -q install
jupyter nbextension install CesiumWidget/static/CesiumWidget --quiet

rm -rf /usr/local/share/jupyter/nbextensions/CesiumWidget/cesium
rm -rf /usr/local/lib/python2.7/dist-packages/CesiumWidget-0.1.0-py2.7.egg/CesiumWidget/static/CesiumWidget/cesium
ln -s /var/www/html/cesium /usr/local/share/jupyter/nbextensions/CesiumWidget/
ln -s /var/www/html/cesium /usr/local/lib/python2.7/dist-packages/CesiumWidget-0.1.0-py2.7.egg/CesiumWidget/static/CesiumWidget/

cd ../
rm -rf CesiumWidget

