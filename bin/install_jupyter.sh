#!/bin/sh
# Copyright (c) 2013-2016 The Open Source Geospatial Foundation.
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
# This script will install jupyter and jupyter-notebook in ubuntu
# The future may hold interesting graphical examples using notebook + tools

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"
BUILD_DIR=`pwd`

apt-get install --assume-yes  python-matplotlib \
        python-scipy python-pandas \
        python-netcdf python-netcdf4 \
        python-shapely python-rasterio python-fiona \
        python-geopandas python-descartes \
        python-enum34 python-geojson python-folium


#-- Jupyter ppa
apt-add-repository --yes ppa:gcpp-kalxas/jupyter
apt-get update

# From Jupyter 1.0.0 setup.py dependencies
apt-get install --assume-yes python-notebook python-qtconsole python-jupyter-console python-nbconvert python-ipykernel python-ipywidgets python-ipython

#-- Clean-up
apt-add-repository --yes --remove ppa:gcpp-kalxas/jupyter

# Get Jupyter and IPython logos
cp "$BUILD_DIR"/../app-data/jupyter/jupyter.svg \
   /usr/share/icons/hicolor/scalable/apps/jupyter.svg

cp "$BUILD_DIR"/../app-data/jupyter/jupyter-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/jupyter-notebook*.desktop

cp "$BUILD_DIR"/../app-data/jupyter/jupyter_*.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter_*.sh

## feb16 rename to jupyter dir
mkdir -p "$USER_HOME/jupyter"
git clone https://github.com/OSGeo/IPython_notebooks \
   "$USER_HOME/jupyter/notebooks"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/jupyter"

##-- 8.0b1  simple example, launch not resolved
cp "$BUILD_DIR"/../app-data/jupyter/cartopy_simple.ipynb \
   "$USER_HOME/jupyter/notebooks/"
cp -r /home/user/jupyter /etc/skel

# gist utility (ruby + jist extension = 15 mb)
#apt-get --assume-yes install ruby ruby-dev
#gem install jist

#
# TODO :  add a proper osgeolive profile inclusing js extensions such reveal.js
#         and few other notebook extensions
#         instructions to do so can be stored on a extra script to run from a live session

if [ ! -d "/etc/skel/.ipython/profile_default" ] ; then
   mkdir -p "/etc/skel/.ipython/profile_default"
   cp -r "$BUILD_DIR"/../app-data/jupyter/static/ \
      /etc/skel/.ipython/profile_default/
fi

if [ ! -d "/etc/skel/.ipython/nbextensions" ] ; then
   mkdir -p "/etc/skel/.ipython/nbextensions"
   cp -r "$BUILD_DIR"/../app-data/jupyter/nbextensions/* \
      /etc/skel/.ipython/nbextensions/
   # these only exist after build is complete, so dangling symlinks during the build
   ln -s /var/www/html/openlayers/ /etc/skel/.ipython/nbextensions/
   ln -s /var/www/html/reveal.js/ /etc/skel/.ipython/nbextensions/ 
fi


####
./diskspace_probe.sh "`basename $0`" end
