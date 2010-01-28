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
# This script will install OpenLayers 2.8

# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/OpenLayers/

TMP_DIR="/tmp/build_openlayers"
OL_VERSION="2.8"

cd "$TMP_DIR"
if [ ! -e "OpenLayers-$OL_VERSION.tar.gz" ] ; then
      wget --progress=dot:mega "http://openlayers.org/download/OpenLayers-$OL_VERSION.tar.gz"
   else
      echo "... OpenLayers-$OL_VERSION.tar.gz already downloaded"
   fi

tar xzf "OpenLayers-$OL_VERSION.tar.gz"

cp -R OpenLayers-$OL_VERSION/ /var/www/openlayers
chmod -R uga+r /var/www/openlayers

#TODO: Launch script and icon for OpenLayers to take you to a documentation page and examples listing
#TODO: Create local example that uses data from the many wms/wfs sources on the live disc

echo "Finished installing OpenLayers $OL_VERSION."
