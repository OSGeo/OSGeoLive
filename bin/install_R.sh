#!/bin/sh
#################################################
# 
# Purpose: Installation of R, R-spatial packages and python dependencies needed by some qgis plug-in into Xubuntu
# Author:  Massimo Di Stefano <info@geofemengineering.it>
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2009 GeofemEngineering 
#
# Licensed under the GNU LGPL.
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
##################################################

# About:
# =====
# This script will install : R and spatial packages plus python dependencies needed by qgis plugins into Xubuntu

# Running:
# =======
# sudo ./install_PyDep_and_R.sh
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

apt-get --assume-yes install python-rpy python-all-dev libgdal1-dev \
   grass-dev libxml2-dev python-shapely tcl8.5-dev tk8.5-dev \
   libgl1-mesa-dev libglu1-mesa-dev python-setuptools build-essential gfortran libblas-dev

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


#Required for QGIS plugins
easy_install -Z rpy2

#Install packages from debs if available
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/cran.list \
     --output-document=/etc/apt/sources.list.d/cran.list
     
apt-key adv --keyserver subkeys.pgp.net --recv-key E2A11821
     
apt-get update
apt-get --assume-yes install r-cran-adapt r-cran-boot \
  r-cran-matrix r-cran-coda r-cran-foreign \
  r-cran-lattice r-cran-lmtest r-cran-maps r-cran-mgcv \
  r-cran-nlme r-cran-sandwich r-cran-zoo
# package does not exist in Jaunty: r-cran-e1071


#Calls R script to do install with feedback to stdout
R --no-save < installRpackages.r

#Add Desktop shortcut

if [ ! -e /usr/share/applications/r.desktop ] ; then
   cat << EOF > /usr/share/applications/r.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=R
Comment=R Statistical Package
Categories=Application;Education;Geography;
Exec=R
Icon= /usr/share/R/doc/html/logo.jpg
Terminal=true
StartupNotify=false
EOF
fi

cp -a /usr/share/applications/r.desktop "$USER_HOME/Desktop/"

#Remove build libraries
apt-get --assume-yes remove python-all-dev libgdal1-dev grass-dev \
   libxml2-dev tcl8.5-dev tk8.5-dev libgl1-mesa-dev libglu1-mesa-dev 
