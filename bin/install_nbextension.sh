#!/bin/sh
#
# install_nbextension.sh
#
#############################################################################
# Created by Massimo Di Stefano on 07/12/09.
# Copyright (c) 2010-2016 Open Source Geospatial Foundation (OSGeo)
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

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_nbextension.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_nbextension.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_ossim
APP_DATA_DIR="$BUILD_DIR/../app-data/notebooks"
SHARED_FOLDER="/usr/local/share/jupyter"


#-- Jupyter ppa
apt-add-repository --yes ppa:gcpp-kalxas/jupyter
apt-get update

# 30 mb and w
apt-get install python3-notebook

# install cesiumextension

# dependencies:
#
wget -c --progress=dot:mega "https://launchpad.net/~gcpp-kalxas/+archive/ubuntu/osgeolive/+files/python-czml_0.3.2-0~trusty1_all.deb"
wget -c --progress=dot:mega "https://launchpad.net/~gcpp-kalxas/+archive/ubuntu/osgeolive/+files/python-pygeoif_0.6-1~trusty0_all.deb"

dpkg -i python-pygeoif_0.6-1~trusty0_all.deb
dpkg -i python-czml_0.3.2-0~trusty1_all.deb

git clone https://github.com/OSGeo-live/CesiumWidget
cd CesiumWidget
python setup.py install
jupyter nbextension install CesiumWidget/static/CesiumWidget

rm -rf /usr/local/share/jupyter/nbextensions/CesiumWidget/cesium
rm -rf /usr/local/lib/python2.7/dist-packages/CesiumWidget-0.1.0-py2.7.egg/CesiumWidget/static/CesiumWidget/cesium
ln -s /var/www/html/cesium /usr/local/share/jupyter/nbextensions/CesiumWidget/
ln -s /var/www/html/cesium /usr/local/lib/python2.7/dist-packages/CesiumWidget-0.1.0-py2.7.egg/CesiumWidget/static/CesiumWidget/

cd ../
rm -rf CesiumWidget
rm -rf python-pygeoif_0.6-1~trusty0_all.deb
rm -rf python-czml_0.3.2-0~trusty1_all.deb
