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

apt-get install --assume-yes  git python-pip \
        python-matplotlib python-scipy python-pandas \
        python-netcdf python-netcdf4 \
        python-shapely python-rasterio python-fiona \
        python-geopandas python-descartes \
        python-enum34 python-geojson

#pip install cligj  ## per ticket #1455 -- rasterio requirements
#The deb package in our ppa is way older than the day this requirement was added...

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

### INSTALL JUPYTERHUB ###

#apt-get update
#apt-get upgrade
# apt-get install gnome-terminal # few kb to make terminal experience much more enjoyable (copy/paste drug'n'drop)

# jupyterhub depends on python3
apt-get install python3-pip
npm install -g configurable-http-proxy
# be sure build toold and libs are here
apt-get install build-essential python-dev
apt-get install python3.4-dev
apt-get install libzmq3-dev
apt-get install libcurl4-openssl-dev
# main dependences for python 3
pip3 install zmq
pip3 install jsonschema
pip3 install terminado
# install jupyterhub from git repository
git clone https://github.com/jupyter/jupyterhub.git
cd jupyterhub
pip install -r requirements.txt
pip3 install -r requirements.txt
pip3 install .
cd ..
rm -rf jupyterhub
# add python 2 and 3 kernels
python -m IPython kernelspec install-self
python3 -m IPython kernelspec install-self
# add bash kernel
pip3 install bash_kernel
# install R kernel
Rscript "$BUILD_DIR"/../app-data/ipython/ir_kernel.r
# add octave kernel
apt-get install octave # 53.5 MB of additional disk space
pip3 install octave_kernel


cp "$BUILD_DIR"/../app-data/ipython/jupyter*.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter*.sh

cp "$BUILD_DIR"/../app-data/ipython/ipython-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/ipython-notebook*.desktop

cp "$BUILD_DIR"/../app-data/ipython/jupyterhub_config.py \
  /usr/local/share/jupyter/

####
./diskspace_probe.sh "`basename $0`" end
