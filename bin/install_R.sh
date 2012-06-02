#!/bin/sh
#################################################
# 
# Purpose: Installation of R, R-spatial packages and python dependencies
#	   needed by some qgis plug-in into Xubuntu
# Author:  Massimo Di Stefano <info@geofemengineering.it>
#
#################################################
# Copyright (c) 2010-2011 Open Source Geospatial Foundation (OSGeo)
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
#
# About:
# =====
# This script will install : R and spatial packages plus python
# dependencies needed by qgis plugins into Xubuntu
#
# Running:
# =======
# sudo ./install_PyDep_and_R.sh

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

#Install packages from debs if available
cp ../sources.list.d/cran.list /etc/apt/sources.list.d/

#old key
#apt-key adv --keyserver subkeys.pgp.net --recv-key E2A11821
#new key as of 2/2011, package manager changed
apt-key adv --keyserver keyserver.ubuntu.com --recv-key E084DAB9

#Apparently subkeys.pgp.net decided to refuse requests from the vm for a few hours
# TODO: if key import fails switch to another keyserver
# pgp.mit.edu keyserver.ubuntu.com

apt-get update

#Plugin interaction with R
apt-get --assume-yes install python-rpy python-all-dev libgdal1-dev \
   grass-dev libxml2-dev python-shapely tcl8.5-dev tk8.5-dev \
   libgl1-mesa-dev libglu1-mesa-dev python-setuptools build-essential \
   gfortran libblas-dev liblapack-dev libsprng2-dev libsprng2

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

#Required for QGIS plugins
easy_install -Z rpy2

# R specific packages
apt-get --assume-yes install r-recommended 

#apt-get --assume-yes install r-cran-rgtk2 r-cran-rjava

# package does not exist in Jaunty+: r-cran-e1071
# not found in Lucid: r-cran-adapt

#Calls R script to do install with feedback to stdout
R --no-save < ../app-conf/R/installRpackages.r


# add user to the staff group so that they can install system-wide packages
adduser "$USER_NAME" staff


#Add Desktop shortcut
if [ ! -e /usr/share/applications/r.desktop ] ; then
   cat << EOF > /usr/share/applications/r.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=R Statistics
Comment=R Statistical Package
Categories=Application;Education;Geography;
Exec=R
Icon= /usr/share/R/doc/html/logo.jpg
Terminal=true
StartupNotify=false
EOF
else
  echo "Icon already present."
fi

cp -a /usr/share/applications/r.desktop "$USER_HOME/Desktop/"

#Remove build libraries
apt-get --assume-yes remove python-all-dev libgdal1-dev \
   libxml2-dev tcl8.5-dev tk8.5-dev libgl1-mesa-dev libglu1-mesa-dev libsprng2-dev

#cleanup leftovers
apt-get --assume-yes autoremove



## fix for broken PDFs, fixed in upstream SVN Aug 2011  (bug #769)
mkdir /tmp/build_R
cd /tmp/build_R
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/R/spgrass6_pdf.zip"
unzip spgrass6_pdf.zip
\cp -f *.pdf /usr/local/lib/R/site-library/spgrass6/doc/

