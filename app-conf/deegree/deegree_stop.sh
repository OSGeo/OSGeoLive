#!/bin/sh
#############################################################################
#
# Purpose: This script is used to stop deegree
# Author: Johannes Wilden
# Credits: Judit Mays, Johannes Kuepper, Danilo Bretschneider
#
#############################################################################
# Copyright (c) 2011-2018 Open Source Geospatial Foundation (OSGeo)
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
#############################################################################

## stop tomcat (and deegree webapps):
## kill the deegree-tomcat process
DEE_DIR="/usr/local/lib/deegree-webservices-3.4.32"

## stop tomcat (and deegree webapps)
cd $DEE_DIR
./bin/catalina.sh stop
