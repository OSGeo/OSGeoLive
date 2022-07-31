#!/bin/sh
# Copyright (c) 2013-2022 The Open Source Geospatial Foundation and others.
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
USER_HOME="/home/${USER_NAME}"
USER_DESKTOP="${USER_HOME}/Desktop"
BUILD_DIR=`pwd`
JUPYTER_BUILD_DIR='/tmp/jupyter_build'
mkdir -p ${JUPYTER_BUILD_DIR}
cd ${JUPYTER_BUILD_DIR}

# Install jupyter notebook
apt-get install --assume-yes jupyter-notebook jupyter-client jupyter-nbconvert \
  python3-ipykernel python3-nbformat python3-ipywidgets python3-ipyleaflet

# 12dev -- note ticket #1965 for trial log

# ipython CLI and R kernel as well
apt-get install --assume-yes ipython3 r-cran-irkernel

# Get Jupyter logo
cp "$BUILD_DIR"/../app-data/jupyter/jupyter.svg \
   /usr/share/icons/hicolor/scalable/apps/jupyter.svg

cp "$BUILD_DIR"/../app-data/jupyter/jupyter-notebook.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/jupyter-notebook.desktop

cp "$BUILD_DIR"/../app-data/jupyter/jupyter_start.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter_start.sh

cd "$BUILD_DIR"

##-- o13 R notebook sample ---------------------------------------
mkdir -p "$USER_HOME/jupyter/notebook_gallery/R"
cp "$BUILD_DIR"/../app-data/jupyter/R_spatial_introduction.ipynb \
   "$USER_HOME/jupyter/notebook_gallery/R/"

## -- add R sf Intro page -- minimal size embed
cp "$BUILD_DIR"/../app-data/jupyter/R_Notebooks_splash/*.html \
   "$USER_HOME/jupyter/notebook_gallery/R/"
cp "$BUILD_DIR"/../app-data/jupyter/R_Notebooks_splash/sf_logo.gif \
   "$USER_HOME/jupyter/notebook_gallery/R/"
cp "$BUILD_DIR"/../app-data/jupyter/R_Notebooks_splash/RConsortium.png \
   "$USER_HOME/jupyter/notebook_gallery/R/"

##-- o15  use git repo
cd ${JUPYTER_BUILD_DIR}

git clone --depth=1 https://github.com/OSGeo/OSGeoLive-Notebooks.git
cp -R OSGeoLive-Notebooks/* ${USER_HOME}/jupyter/notebook_gallery/
chown -R ${USER_NAME}:${USER_NAME}  ${USER_HOME}/jupyter/notebook_gallery/*
rm -rf OSGeoLive-Notebooks


cd "$BUILD_DIR"
rm -rf ${JUPYTER_BUILD_DIR}
##--------------------------------------------
cp -r ${USER_HOME}/jupyter /etc/skel

chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}/jupyter

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
