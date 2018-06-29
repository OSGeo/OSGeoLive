#!/bin/sh
# Copyright (c) 2013-2018 The Open Source Geospatial Foundation and others.
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

# Install latest jupyter notebook
apt-get install --assume-yes jupyter-notebook jupyter-client jupyter-nbconvert \
  python-ipykernel python-nbformat python-ipywidgets

# 12dev -- note ticket #1965 for trial log

# ipython CLI as well
apt-get install --assume-yes ipython

##=============================================================
## Add Kernels and Jupyter Mods
##

##--  IRKernel via github (assumes R core)

su - -c "R -e \"install.packages('pbdZMQ')\""
su - -c "R -e \"install.packages('uuid')\""
su - -c "R -e \"install.packages('digest')\""

su - -c "R -e \"install.packages('repr')\""
su - -c "R -e \"install.packages('evaluate')\""
su - -c "R -e \"install.packages('crayon')\""

su - -c "R -e \"install.packages('IRdisplay')\""

apt install --assume-yes libssl-dev openssl
su - -c "R -e \"install.packages('devtools')\""

## method zero -- pull from Github dot com
#su - -c "R -e \"devtools::install_github('IRkernel/IRkernel')\""
#su - -c "R -e \"IRkernel::installspec(user = FALSE)\""

## methode one -- saved, marked copy
JOVYAN_R='IRkernel-master-97c492b2.zip'
wget -c http://download.osgeo.org/livedvd/12/jupyter/${JOVYAN_R}
unzip ${JOVYAN_R}
R CMD INSTALL IRkernel-master
#- TODO check status

su - -c "R -e \"IRkernel::installspec()\""

#- cleanup
rm -rf IRk*


##-----------------------------------

# Get Jupyter logo
cp "$BUILD_DIR"/../app-data/jupyter/jupyter.svg \
   /usr/share/icons/hicolor/scalable/apps/jupyter.svg

cp "$BUILD_DIR"/../app-data/jupyter/jupyter-notebook.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/jupyter-notebook.desktop

cp "$BUILD_DIR"/../app-data/jupyter/jupyter_start.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter_start.sh

# TODO: Test if these notebooks work fine 
# mkdir -p "$USER_HOME/jupyter"
# git clone https://github.com/OSGeo/OSGeoLive-Notebooks.git \
#    "$USER_HOME/jupyter/notebooks"
# chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/jupyter"

cd "$BUILD_DIR"

mkdir -p "$USER_HOME/jupyter/notebooks/projects/CARTOPY"
cp "$BUILD_DIR"/../app-data/jupyter/cartopy_simple.ipynb \
   "$USER_HOME/jupyter/notebooks/projects/CARTOPY/"
cp -r /home/user/jupyter /etc/skel

####
./diskspace_probe.sh "`basename $0`" end
