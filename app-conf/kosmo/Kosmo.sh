#!/bin/sh
#################################################
# 
# Purpose: Kosmo launcher
#
#################################################
# Copyright (c) 2010-2016 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2010 SAIG
#
# Licensed under the GNU GPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, either
# in the "LICENSE.GPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/gpl.html".
##################################################

cd /usr/lib/Kosmo-3.1/bin

KOSMO_LIBS_PATH="../native"
GDAL_LIBS_PATH="../native"
PROJ_LIB="./crs/data"
export PROJ_LIB

if [ -n "$LD_LIBRARY_PATH" ] ; then
    LD_LIBRARY_PATH="$KOSMO_LIBS_PATH:$LD_LIBRARY_PATH"
else
    LD_LIBRARY_PATH="$KOSMO_LIBS_PATH"
fi
export LD_LIBRARY_PATH

if [ -n "$GDAL_DRIVER_PATH" ]; then
	GDAL_DRIVER_PATH=$GDAL_LIBS_PATH:$GDAL_DRIVER_PATH
else
	GDAL_DRIVER_PATH=$GDAL_LIBS_PATH
fi
export GDAL_DRIVER_PATH

java -Djava.library.path=/usr/lib:"../native" \
     -Dsun.java2d.d3d=false \
     -cp .:./kosmo-desktop-core-3.1.jar:./ext/libs/*:./ext/* \
     -Xmx800M "com.vividsolutions.jump.workbench.JUMPWorkbench" \
     -plug-in-directory "./ext"

