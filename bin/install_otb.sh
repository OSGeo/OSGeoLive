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

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

#Add repositories
apt-add-repository --yes ppa:otb/orfeotoolbox-stable    

apt-get update

#Install applications, can we eliminate some? otbapp-legacy?
#otbapp legacy provide standalone application which are demonstrators of some OTB functionnalities
#Lot's of these applications have been ported in modules in monteverdi but there are still remainning applications
#in the legacy not available in monteverdi (simple viewer manager, vector database/raster registration...
#Monteverdi is perhap's sufficient in a first approach,if you need to save space we  can eliminate otbapp-legacy
apt-get --assume-yes install libotb monteverdi

#### install desktop icon ####
cp /usr/share/applications/monteverdi.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/monteverdi.desktop" 

# live disc's username is "user"
DATA_DIR=$USER_HOME/gisvm/app-data/otb
OTB_DATA=/usr/local/share/otb

# Download OrfeoToolBox data and documentation (software guide and cookbook
[ -d $DATA_DIR ] || mkdir $DATA_DIR
[ -f $DATA_DIR/OTBSoftwareGuide.pdf ] || \
   wget --progress=dot:mega "http://www.orfeo-toolbox.org/packages/OTBSoftwareGuide.pdf" \
     -O $DATA_DIR/OTBSoftwareGuide.pdf
[ -f $DATA_DIR/OTBCookBook.pdf ] || \
   wget --progress=dot:mega "http://www.orfeo-toolbox.org/packages/OTBCookBook.pdf" \
     -O $DATA_DIR/OTBCookBook.pdf
#[ -f $DATA_DIR/OTB-Data-Examples.tgz ] || \
   #wget --progress=dot:mega "http://www.orfeo-toolbox.org/packages/OTB-Data-Examples.tgz" \
     #-O $DATA_DIR/OTB-Data-Examples.tgz

# Install docs and demos
if [ ! -d "$OTB_DATA" ]; then
    mkdir -p "$OTB_DATA/demos"
    echo "Moving  OTB pdf  doc in $OTB_DATA/....."
    mv "$DATA_DIR/OTBSoftwareGuide.pdf" "$OTB_DATA/"
    echo "Done"
    echo "Moving  OTB cookbook pdf  doc in $OTB_DATA/....."
    mv "$DATA_DIR/OTBCookBook.pdf" "$OTB_DATA/"
    echo "Done"
    #echo "Extracting OTB data examples $OTB_DATA/demos/..."
    #tar xzf "$DATA_DIR/OTB-Data-Examples.tgz" -C $OTB_DATA/demos/ 
    #echo "Done"
fi


#MONTEVERDI plugin can't do this for now since it requires a recompile of MONTEVERDI according to the docs
#TODO install otb qgis plugins when it will be available with debian packages
#hg clone http://hg.orfeo-toolbox.org/OTB-QGis-plugins


