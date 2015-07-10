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
        python-netcdf python-shapely python3-setuptools \
        python-enum34  python3-numpy python3-scipy python-simplegeneric python-zmq \
        python3-pandas python3-matplotlib python3-shapely python-gdal python3-gdal \
        python-enum34 python3-enum34 python-six python3-six python-pyproj python3-pyproj

apt-get install --assume-yes python3-pip python3-zmq python3-jsonschema python3-jinja2 python3-sqlalchemy python3-requests python3-decorator python3-simplegeneric python3-pyside python3-pygments

cp "$BUILD_DIR"/../app-data/ipython/ipython-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/ipython-notebook*.desktop

cp "$BUILD_DIR"/../app-data/ipython/jupyter-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/jupyter-notebook*.desktop

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

# install
# extra python packages not available on standard debian repository

# Cython
#wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-cython_0.22.1_$ARCH.deb"
#dpkg -i python2-cython_0.22.1_$ARCH.deb


wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-affine_1.2.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-click_4.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-snuggs_1.3.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-cligj_0.2.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-fiona_1.6.0pre0_$ARCH.deb"

dpkg -i python2-affine_1.2.0_all.deb
dpkg -i python2-click_4.0_all.deb
dpkg -i python2-snuggs_1.3.1_all.deb
dpkg -i python2-cligj_0.2.0_all.deb
dpkg -i python2-fiona_1.6.0pre0_$ARCH.deb

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-affine_1.2.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-click_4.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-snuggs_1.3.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-cligj_0.2.0_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-fiona_1.6.0pre0_$ARCH.deb"

dpkg -i python3-affine_1.2.0_all.deb
dpkg -i python3-click_4.0_all.deb
dpkg -i python3-snuggs_1.3.1_all.deb
dpkg -i python3-cligj_0.2.0_all.deb
dpkg -i python3-fiona_1.6.0pre0_$ARCH.deb


wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-rasterio_0.24.1_$ARCH.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-netcdf4_1.1.9_$ARCH.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-descartes_1.0.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-geojson_1.2.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python2-geopandas_0.1.1_all.deb"

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-rasterio_0.24.1_$ARCH.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-netcdf4_1.1.9_$ARCH.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-descartes_1.0.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-geojson_1.2.1_all.deb"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/python3-geopandas_0.1.1_all.deb"



dpkg -i python2-rasterio_0.24.1_$ARCH.deb
dpkg -i python2-netcdf4_1.1.9_$ARCH.deb
dpkg -i python2-descartes_1.0.1_all.deb
dpkg -i python2-geojson_1.2.1_all.deb
dpkg -i python2-geopandas_0.1.1_all.deb

dpkg -i python3-rasterio_0.24.1_$ARCH.deb
dpkg -i python3-netcdf4_1.1.9_$ARCH.deb
dpkg -i python3-descartes_1.0.1_all.deb
dpkg -i python3-geojson_1.2.1_all.deb
dpkg -i python3-geopandas_0.1.1_all.deb

#python3-cython_0.22.1_i386.deb
#python2-cython_0.22.1_i386.deb


# install jupyter, ipython and co...


wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyter-share-hub_1.0_all.deb"
#wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/debs/Jupyter-debs/jupyterhub_1.0_all.deb"
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
#dpkg -i jupyterhub_1.0_all.deb
dpkg -i jupyter-bash-kernel_1.0_all.deb
dpkg -i python2-ipywidgets_4.0.0.dev_all.deb
dpkg -i python3-ipyparallel_4.0.0.dev_all.deb
dpkg -i python2-pexpect_4.0.dev_all.deb
dpkg -i python2-ptyprocess_0.5_all.deb
dpkg -i python2-bash-kernel_0.3_all.deb

# add octave kernel
apt-get --assume-yes install octave # 53.5 MB of additional disk space
pip3 install octave_kernel

cp "$BUILD_DIR"/../app-data/ipython/jupyter*.sh \
   /usr/local/bin/
chmod a+x /usr/local/bin/jupyter*.sh

cp "$BUILD_DIR"/../app-data/ipython/ipython-notebook*.desktop \
   "$USER_DESKTOP"/
chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/ipython-notebook*.desktop

cp "$BUILD_DIR"/../app-data/ipython/jupyterhub_config.py \
  /usr/local/share/jupyter/



wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/launchers/jupyter.png"
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/launchers/ipynb.png"
#wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ipython/launchers/jupyter.desktop"
#mv jupyter.desktop /usr/share/applications/jupyter.desktop
mv jupyter.png /usr/local/share/jupyter/jupyter.png
mv ipynb.png /usr/local/share/jupyter/ipynb.png
chown "$USER_NAME:$USER_NAME" /usr/local/share/jupyter/jupyter.png
chown "$USER_NAME:$USER_NAME" /usr/local/share/jupyter/ipynb.png


# install R kernel

cp ../sources.list.d/cran.list /etc/apt/sources.list.d/

#old key
#apt-key adv --keyserver subkeys.pgp.net --recv-key E2A11821
#new key as of 2/2011, package manager changed
apt-key adv --keyserver keyserver.ubuntu.com --recv-key E084DAB9

#Apparently subkeys.pgp.net decided to refuse requests from the vm for a few hours
# TODO: if key import fails switch to another keyserver
# pgp.mit.edu keyserver.ubuntu.com

apt-get -q update
apt-get --assume-yes install r-base r-base-core r-cran-rcurl libcurl4-openssl-dev libxml2-dev libzmq3-dev

Rscript "$BUILD_DIR"/../app-data/ipython/ir_kernel.r

mv /home/user/.local/share/jupyter/kernels/ir /usr/local/share/jupyter/kernels/ir
rm -rf /home/user/.local/share/jupyter
chmod -R 777 /usr/local/share/jupyter/kernels/ir/

####
./diskspace_probe.sh "`basename $0`" end

