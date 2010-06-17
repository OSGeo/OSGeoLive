#!/bin/sh
#################################################
# 
# Purpose: Synchronise a Live DVD with the latest working version stored
#          on OSGeo servers.
# Author:  Cameron Shorter
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
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

# Running:
# =======
# ./sync_livedvd <your osgeo username>
# This is intended to be run from the LiveDVD.
# You will be prompted for the LiveDVD password = user
# Then you will be prompted for your osgeo
# user's password = <you should know this>


USER=${1}

#if [ $USER == "-h" || ! $USER ] ; then
if [ ! $USER ] ; then
  echo "Usage: ${0} <your osgeo username>"
  echo " This script is intended to be run from the LiveDVD."
  echo " You will be prompted for the LiveDVD password = user"
  echo " Then you will be prompted for your osgeo"
  echo " username's password = <you should know this>"
  exit 1;
fi;
echo ${1} 

# Pull down synchronisation files from OSGeo server
sudo rsync -az ${USER}@download.osgeo.org:/osgeo/download/livedvd/working_livedvd/ /

# Push up synchronisation files to OSGeo server
# sudo rsync -az /bin camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /boot camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /etc camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /lib camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /home camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /sbin camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/
# sudo rsync -az /usr camerons@upload.osgeo.org:/osgeo/download/livedvd/working_livedvd/

