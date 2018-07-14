#!/bin/sh

# IRIS (C) British Crown Copyright 2010 - 2013, Met Office
# Licensed under the GNU LGPL.
#
# Iris is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Iris is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Iris. If not, see <http://www.gnu.org/licenses/>.
#
# About:
# =====
# This script will install Iris

./diskspace_probe.sh "`basename $0`" begin

BUILD_DIR=`pwd`
TMP_DIR=/tmp/iris_build
mkdir -p "$TMP_DIR"

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
####

apt-get install -y python-iris
apt-get install -y netcdf-bin

##-- 29jul14 odd errors installing netCDF, add workarounds
# apt-get install libpython2.7-dev

# Install additional python packages using pip:
#echo "FIXME: try not to use pip. prefer a deb instead. see pypi-install in install_tilemill.sh for an example."
#pip install netCDF4 pyshp
# easy_install netCDF4
# wget https://bootstrap.pypa.io/ez_setup.py
# python ez_setup.py
# pip install netCDF4
# rm -f ez_setup.py setuptools-5*

# ## in any case, matplotlib is required
# if [ ! -e /usr/share/pyshared/matplotlib ] ; then
#     ## closed in tickets #1271 #1285 commentary/attachments
#     apt-get install -y python-matplotlib
#     # xx   -> matplotlib 1.1.1rc
#
#     #pip install matplotlib
#     #pip install --upgrade matplotlib
#     #   -> matplotlib 1.3.1
# fi

# # Build and install grib_api (optional):
# mkdir /tmp/build_iris
# cd /tmp/build_iris
#
# wget --no-check-certificate -c --progress=dot:mega \
#   "https://software.ecmwf.int/wiki/download/attachments/3473437/grib_api-1.9.16.tar.gz"
#
# tar xzf grib_api-1.9.16.tar.gz
#
# cd grib_api-1.9.16
# ./configure --enable-python
# make
# make install
#
# echo "/usr/local/lib/python2.7/site-packages/grib_api" > gribapi.pth
# cp gribapi.pth /usr/local/lib/python2.7/dist-packages/
#
# # Build and install the PP packing library (optional):
# #cd /tmp/build_iris
# #wget -c -nv \
# #  "https://puma.nerc.ac.uk/trac/UM_TOOLS/raw-attachment/wiki/unpack/unpack-030712.tgz"
# #
# #tar xzf "unpack-030712.tgz"
# #
# #cd unpack-030712
# #cd libmo_unpack
# #
# #wget -c -nv \
# #  "https://raw.github.com/scitools/installation-recipes/master/xubuntu12.04/unpack-030712_xubuntu.patch"
# #
# #patch -p2 < "unpack-030712_xubuntu.patch"
# #
# #bash ./make_library
# #./distribute.sh /usr/local
# #
# ldconfig

# # Install Cartopy dependancy: (6 MB)
# cd /tmp/build_iris
# wget --progress=dot:mega -O cartopy.zip \
#   "https://github.com/SciTools/cartopy/archive/v0.11.0.zip"
# unzip -q cartopy.zip
#
# cd cartopy-0.11.0
# python setup.py install
#
# # Install Iris: (3.5 MB)
# cd /tmp/build_iris
# wget --progress=dot:mega -O iris.zip \
#   "https://github.com/SciTools/iris/archive/v1.6.1.zip"
#
# unzip -q iris.zip
#
# cd iris-1.6.1
# #python setup.py --with-unpack install
# python setup.py install
# #touch /usr/local/lib/python2.7/dist-packages/Iris-1.6.1-py2.7-linux-i686.egg/iris/fileformats/_pyke_rules/compiled_krb/*
#
# # Tidy up
# apt-get --yes remove python-dev libhdf5-serial-dev libnetcdf-dev \
#                libgeos-dev libproj-dev libpython2.7-dev\
# 	       libjasper-dev libfreetype6-dev libpng-dev tk-dev

rm -rf /usr/lib/python2.7/dist-packages/iris/tests/*pyc
rm -rf /usr/lib/python2.7/dist-packages/iris/tests/results/*
#rm -rf /usr/local/lib/python2.7/dist-packages/iris/tests

#rm -rf /usr/local/lib/python2.7/dist-packages/cartopy/data \
#       /usr/local/lib/python2.7/dist-packages/cartopy/examples \
#       /usr/local/lib/python2.7/dist-packages/cartopy/sphinxext \
#       /usr/local/lib/python2.7/dist-packages/cartopy/tests \
#       /usr/local/lib/python2.7/dist-packages/Iris-1.6.1-py2.7-linux-i686.egg/iris/tests


## Live 8.5 -- pre-cache natural_earth 110m shapefiles
cd "$TMP_DIR"
wget -c http://download.osgeo.org/livedvd/data/cartopy/natural_earth_cartopy.tgz
if [ ! -e natural_earth_cartopy.tgz ]; then
  echo "Download of cartopy cache files failed"
  exit 1
fi

tar xzf natural_earth_cartopy.tgz

mkdir -p ${USER_HOME}/.local/share/cartopy/shapefiles
mv natural_earth /home/user/.local/share/cartopy/shapefiles/
chown --recursive ${USER_NAME}:${USER_NAME} /home/user/.local/share/cartopy

## 12dev  cartopy fast image  126K
mkdir -p /usr/lib/python2.7/dist-packages/cartopy/data/raster/natural_earth
wget http://download.osgeo.org/livedvd/12/cartopy/50-natural-earth-1-downsampled.png \
      -O /usr/lib/python2.7/dist-packages/cartopy/data/raster/natural_earth/50-natural-earth-1-downsampled.png

## 3.6MB demo tif
wget http://download.osgeo.org/livedvd/12/rasterio/SanMateo_CA.tif \
    -O ${USER_HOME}/data/
##----------------------------
##
## 12dev  folium install via git snapshot
apt install python-setuptools --yes
F_DIR=folium_build
cd /tmp; mkdir ${F_DIR}; cd ${F_DIR}
wget -c http://download.osgeo.org/livedvd/12/folium/folium-0.5.a3c6994.tar.gz
wget -c http://download.osgeo.org/livedvd/12/folium/branca-0.3.a2e2281.tar.gz

tar xf branca-0.3.a2e2281.tar.gz
tar xf folium-0.5.a3c6994.tar.gz

cd branca-0.3.0
python setup.py build
python setup.py install
cd ..

cd folium-0.5.0
python setup.py build
python setup.py install
cd ..

##-- SciTools/nc-time-access is pure-python w/ no depends; mv signed pkg dir to install
N_DIR=nc_build
cd /tmp;mkdir ${N_DIR}; cd ${N_DIR}
wget -c http://download.osgeo.org/livedvd/12/cartopy/nc-time-axis-1.1.d9956a7.tar.gz
tar xf nc-time-axis-1.1.d9956a7.tar.gz
cd nc-time-axis-1.1.0; rm -rf nc_time_axis/tests
mv nc_time_axis /usr/local/lib/python2.7/dist-packages/

##-- palettable is pure-python w/ no depends; mv signed pkg dir to install
P_DIR=plt_build
cd /tmp; mkdir ${P_DIR}; cd ${P_DIR}
wget -c https://files.pythonhosted.org/packages/56/8a/84537c0354f0d1f03bf644b71bf8e0a50db9c1294181905721a5f3efbf66/palettable-3.1.1-py2.py3-none-any.whl
 mv palettable-3.1.1-py2.py3-none-any.whl palettable-3.1.1-py2.py3-none-any.zip
unzip -o palettable-3.1.1-py2.py3-none-any.zip
mv palettable /usr/local/lib/python2.7/dist-packages/

cd /tmp
rm -rf /tmp/${F_DIR}
rm -rf /tmp/${P_DIR}

apt-get remove --yes python-setuptools
##---------------------------------------------------

cd /tmp
rm -rf "$TMP_DIR"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
