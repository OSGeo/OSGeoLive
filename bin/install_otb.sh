#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will install Orfeo Tooblox including Monteverdi and OTB apps, assumes script is run with sudo priveleges.

# Running:
# =======
# monteverdi
# TODO: list all the apps, preferably Qt versions in /usr/bin/?

#Add repositories
apt-add-repository ppa:ubuntugis/ubuntugis-unstable  
add-apt-repository ppa:otb/orfeotoolbox-stable-ubuntugis 

apt-get update

#Install applications, can we eliminate some? otbapp-legacy?
apt-get --assume-yes install libotb otbapp monteverdi


# live disc's username is "user"
DATA_DIR=$USER_HOME/gisvm/app-data/otb
OTB_DATA=/usr/local/share/otb

# Download OrfeoToolBox data and documentation
[ -d $DATA_DIR ] || mkdir $DATA_DIR
[ -f $DATA_DIR/OTBSoftwareGuide.pdf ] || \
   wget -c "http://www.orfeo-toolbox.org/packages/OTBSoftwareGuide.pdf" \
     -O $DATA_DIR/OTBSoftwareGuide.pdf
[ -f $DATA_DIR/OTB-Data-Examples.tgz ] || \
   wget -c "http://www.orfeo-toolbox.org/packages/OTB-Data-Examples.tgz" \
     -O $DATA_DIR/OTB-Data-Examples.tgz

# Install docs and demos
if [ ! -d $OTB_DATA ]; then
    mkdir -p $OTB_DATA/demos
    echo -n "Moving  OTB pdf  doc in $OTB_DATA/....."
    mv $DATA_DIR/OTBSoftwareGuide.pdf $OTB_DATA/

    echo -n "Done\nExtracting OTB data examples $OTB_DATA/demos/..."
    tar -xzvf -q $DATA_DIR/OTB-Data-Examples.tgz -d $OTB_DATA/demos/ 
    echo -n "Done\n"
fi

#TODO
#Add Launch icon to desktop
#What Icon should be used?


#QGIS plugin can't do this for now since it requires a recompile of QGIS according to the docs
#hg clone http://hg.orfeo-toolbox.org/OTB-Qgis-plugins



