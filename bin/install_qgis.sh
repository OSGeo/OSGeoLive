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
# This script will install Quantum GIS including python and GRASS support, assumes script is run with sudo priveleges. NOTE: Untested, I don't know the sudo password for the VM

# Running:
# =======
# qgis


#Add repositories
#echo -e "deb http://ppa.launchpad.net/qgis/stable/ubuntu jaunty main \ndeb-src http://#ppa.launchpad.net/qgis/stable/ubuntu jaunty main" > /etc/apt/sources.list.d/qgis.list
 
#alternate method
wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/qgis.list --output-document=/etc/apt/sources.list.d/qgis.list

#Add signed key for repo
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1024R/68436DDF 

#Latest Dev Release, Mrsid, ECW
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys  	  1024R/314DF160  

apt-get update

#Install packages
apt-get install qgis qgis-common qgis-plugin-grass python-qgis python-qgis-common qgis-plugin-grass-common libgdal1-1.5.0-grass

#Make sure old qt uim isn't installed
apt-get remove uim-qt uim-qt3

#for unstable version
#apt-get install qgis qgis-common qgis-plugin-grass python-qgis python-qgis-common #qgis-plugin-grass-common libgdal1-1.6.0-grass

#TODO Install some popular python plugins
#Use wget to pull them directly into qgis python path?

#TODO Include some sample projects using already installed example data
#post a sample somewhere on qgis website or launchpad to pull
