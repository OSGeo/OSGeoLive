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
#apt-add-repository --yes ppa:jtaylor/ipython
#apt-get update

#apt-get install --assume-yes ipython ipython-notebook ipython-qtconsole

#-- Clean-up
#apt-add-repository --yes --remove ppa:jtaylor/ipython

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


if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_java.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_ossim.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"



wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-share-hub_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-python3-kernel_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-python2-kernel_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ptyprocess_0.5_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ptyprocess_0.5_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-pexpect_4.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-pexpect_4.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-bash-kernel_0.3_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ipyparallel_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ipywidgets_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-backports.ssl-match-hostname_3.4.0.2_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-certifi_2015.04.28_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-notebook_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-traitlets_4.1.0.dev_all.deb"

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-tornado_4.2_$ARCH.deb"

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-qtconsole_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-terminado_0.5_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-pickleshare_0.5_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-path.py_7.3_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-octave-kernel_0.11.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-nbformat_4.1.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ipykernel_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-nbconvert_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-jupyter-core_4.1.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-jupyter-console_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-jupyter-client_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ipywidgets_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ipython-genutils_0.2.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ipython_4.0.0-dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-ipyparallel_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-bash-kernel_0.3_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-traitlets_4.1.0.dev_all.deb"

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-tornado_4.2_$ARCH.deb"

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-pickleshare_0.5_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-path.py_7.3_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-jupyter-core_4.1.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-jupyter-client_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ipykernel_4.0.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-share-hub_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-python2-kernel_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ipython-genutils_0.2.0.dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-ipython_4.0.0-dev_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-python3-kernel_1.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-bash-kernel_1.0_all.deb"

apt-get install python3-pip python3-zmq python3-jsonschema python3-jinja2 python3-sqlalchemy python3-requests python3-decorator python3-simplegeneric python3-pyside python3-pygments



dpkg -i python3-tornado_4.2_$ARCH.deb
dpkg -i python3-traitlets_4.1.0.dev_all.deb
dpkg -i python3-jupyter-core_4.1.0.dev_all.deb
dpkg -i python3-nbformat_4.1.0.dev_all.deb
dpkg -i python3-jupyter-client_4.0.0.dev_all.deb
dpkg -i python3-ipython_4.0.0-dev_all.deb
dpkg -i python3-ipykernel_4.0.0.dev_all.deb
dpkg -i python3-nbconvert_4.0.0.dev_all.deb
dpkg -i python3-ipython-genutils_0.2.0.dev_all.deb
dpkg -i python3-ptyprocess_0.5_all.deb
dpkg -i python3-terminado_0.5_all.deb
dpkg -i python3-path.py_7.3_all.deb
dpkg -i python3-pickleshare_0.5_all.deb
dpkg -i python3-notebook_4.0.0.dev_all.deb
dpkg -i python3-ipyparallel_4.0.0.dev_all.deb
dpkg -i python3-ipywidgets_4.0.0.dev_all.deb
dpkg -i python3-jupyter-console_4.0.0.dev_all.deb
dpkg -i python3-qtconsole_4.0.0.dev_all.deb
dpkg -i python3-pexpect_4.0.dev_all.deb
dpkg -i python3-bash-kernel_0.3_all.deb

dpkg -i jupyter-python2-kernel_1.0_all.deb
dpkg -i python2-ipykernel_4.0.0.dev_all.deb
dpkg -i python2-ipython_4.0.0-dev_all.deb
dpkg -i python2-ipython-genutils_0.2.0.dev_all.deb
dpkg -i python2-jupyter-client_4.0.0.dev_all.deb
dpkg -i python2-jupyter-core_4.1.0.dev_all.deb
dpkg -i python2-path.py_7.3_all.deb
dpkg -i python2-pickleshare_0.5_all.deb
dpkg -i python2-certifi_2015.04.28_all.deb
dpkg -i python2-backports.ssl-match-hostname_3.4.0.2_all.deb
dpkg -i python2-tornado_4.2_$ARCH.deb
dpkg -i python2-traitlets_4.1.0.dev_all.deb
dpkg -i jupyter-share-hub_1.0_all.deb
dpkg -i jupyter-bash-kernel_1.0_all.deb
dpkg -i python2-ipywidgets_4.0.0.dev_all.deb
dpkg -i python3-ipyparallel_4.0.0.dev_all.deb
dpkg -i python2-pexpect_4.0.dev_all.deb
dpkg -i python2-ptyprocess_0.5_all.deb
dpkg -i python2-bash-kernel_0.3_all.deb


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

