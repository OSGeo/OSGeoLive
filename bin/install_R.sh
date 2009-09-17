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



apt-get install python-rpy python-all-dev libgdal1-dev grass-dev libxml2-dev python-shapely tcl8.4-dev tk8.4-dev libgl1-mesa-dev libglu1-mesa-dev python-setuptools

easy_install rpy2

echo 'packagelist <- c("adapt","boot","class","classInt","coda","DCluster","digest","e1071","epitools","foreign","gpclib","graph","gstat","lattice","lmtest","maps","maptools","Matrix","mgcv","nlme","pgirmess","pkgDepTools","R2WinBUGS","RandomFields","RBGL","RColorBrewer","rgdal","Rgraphviz","sandwich","sp","spam","spatialkernel","spatstat","spdep","spgrass6","spgwr","splancs","tripack","xtable","zoo")
for (i in packagelist) {
    install.packages(i, repos= "http://cran.r-project.org", lib = "/usr/local/lib/R/site-library/" , dependencies = TRUE)
}' > /tmp/installRpackages.r

R CMD BATCH /tmp/installRpackages.r

apt-get remove python-all-dev libgdal1-dev grass-dev libxml2-dev tcl8.4-dev tk8.4-dev libgl1-mesa-dev libglu1-mesa-dev 