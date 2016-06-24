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

apt-get install --assume-yes python-folium \
        python-pysal python-geocoder

#-- Jupyter ppa
apt-add-repository --yes ppa:gcpp-kalxas/jupyter
apt-get update

# From Jupyter 1.0.0 setup.py dependencies
apt-get install --assume-yes python-notebook python-qtconsole \
        python-jupyter-console python-nbconvert python-ipykernel \
        python-ipywidgets python-ipython python-terminado

# upgrade notebook and widgets to new version, needed by leaflet and ney jupyter widget system
wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/jupyter/debs/python-notebook_4.2.1_all.deb"

wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/jupyter/debs/python-ipywidgets_5.1.5_all.deb"

wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/jupyter/debs/python-widgetsnbextension_1.2.3_all.deb"

dpkg -i python-notebook_4.2.1_all.deb
dpkg -i python-widgetsnbextension_1.2.3_all.deb
dpkg -i python-ipywidgets_5.1.5_all.deb

#-- Clean-up
apt-add-repository --yes --remove ppa:gcpp-kalxas/jupyter

# Get Jupyter logo
cp "$BUILD_DIR"/../app-data/jupyter/jupyter.svg \
   /usr/share/icons/hicolor/scalable/apps/jupyter.svg

cp "$BUILD_DIR"/../app-data/jupyter/jupyter-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/jupyter-notebook*.desktop

cp "$BUILD_DIR"/../app-data/jupyter/jupyter_*.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter_*.sh

mkdir -p "$USER_HOME/jupyter"
git clone https://github.com/OSGeo/OSGeoLive-Notebooks.git \
   "$USER_HOME/jupyter/notebooks"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/jupyter"

cd /tmp
wget -c --tries=3 --progress=dot:mega \
  "http://download.osgeo.org/livedvd/9.5/jupyter/iris/sample_data.tgz"
tar xf sample_data.tgz
mkdir -p "$USER_HOME/jupyter/notebooks/projects/IRIS"
mv sample_data "$USER_HOME/jupyter/notebooks/projects/IRIS/"
cd "$BUILD_DIR"

/bin/sh ../app-conf/jupyter/install_nbextension.sh

mkdir -p "$USER_HOME/jupyter/notebooks/projects/CARTOPY"
cp "$BUILD_DIR"/../app-data/jupyter/cartopy_simple.ipynb \
   "$USER_HOME/jupyter/notebooks/projects/CARTOPY/"
cp -r /home/user/jupyter /etc/skel

# add geoalchemy to easy access to postgis from python
wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/jupyter/debs/python-geoalchemy2_0.3.0_all.deb"
dpkg -i

# add ipyleaflet
wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/jupyter/debs/python-ipyleaflet_0.2.0_all.deb"
dpkg -i python-ipyleaflet_0.2.0_all.deb

jupyter nbextension enable --py --sys-prefix widgetsnbextension
jupyter nbextension enable --py --sys-prefix ipyleaflet

####
./diskspace_probe.sh "`basename $0`" end
