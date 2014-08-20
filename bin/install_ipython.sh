#!/bin/sh
# Copyright (c) 2013 The Open Source Geospatial Foundation.
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
# This script will install ipython and ipython-notebook in ubuntu
# The future may hold interesting graphical examples using notebook + tools

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"
BUILD_DIR=`pwd`

## 24jan14  change in iPython+numpy+matplotlib
## 04jul14  jtaylor iPython

apt-get install --assume-yes git python-scipy python-pandas python-netcdf \
        python-rasterio python-fiona python-matplotlib

#-- iPython from jtaylor .deb
apt-add-repository --yes ppa:jtaylor/ipython
apt-get update

apt-get install --assume-yes ipython ipython-notebook ipython-qtconsole

#-- Clean-up
apt-add-repository --yes --remove ppa:jtaylor/ipython

cp "$BUILD_DIR"/../app-data/ipython/ipython-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/ipython-notebook*.desktop


cp "$BUILD_DIR"/../app-data/ipython/ipython_*.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/ipython_*.sh

mkdir -p "$USER_HOME/ipython"
git clone https://github.com/OSGeo/IPython_notebooks \
   "$USER_HOME/ipython/notebooks"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/ipython"

##-- 8.0b1  simple example, launch not resolved
cp "$BUILD_DIR"/../app-data/ipython/cartopy_simple.ipynb \
   "$USER_HOME/ipython/notebooks/"
cp -r /home/user/ipython /etc/skel

# gist utility (ruby + jist extension = 15 mb)
#apt-get --assume-yes install ruby ruby-dev
#gem install jist

#
# TODO :  add a proper osgeolive profile inclusing js extensions such reveal.js
#         and few other notebook extensions
#         instructions to do so can be stored on a extra script to run from a live session

if [ ! -d "/etc/skel/.ipython/profile_default" ] ; then
   mkdir -p "/etc/skel/.ipython/profile_default"
   cp -r "$BUILD_DIR"/../app-data/ipython/static/ \
      /etc/skel/.ipython/profile_default/
fi

if [ ! -d "/etc/skel/.ipython/nbextensions" ] ; then
   mkdir -p "/etc/skel/.ipython/nbextensions"
   cp -r "$BUILD_DIR"/../app-data/ipython/nbextensions/* \
      /etc/skel/.ipython/nbextensions/
   # these only exist after build is complete, so dangling symlinks during the build
   ln -s /var/www/html/openlayers/ /etc/skel/.ipython/nbextensions/
   ln -s /var/www/html/reveal.js/ /etc/skel/.ipython/nbextensions/ 
fi


####
./diskspace_probe.sh "`basename $0`" end
