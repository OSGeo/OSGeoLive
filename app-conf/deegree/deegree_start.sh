#!/bin/sh
#############################################################################
#
# Purpose: This script is used to start deegree
# Author: Johannes Wilden
# Credits: Judit Mays, Johannes Kuepper, Danilo Bretschneider
#
#############################################################################
# Copyright (c) 2011-2022 Open Source Geospatial Foundation (OSGeo)
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

DEEGREE_WORKSPACE_ROOT="/usr/local/share/deegree"
export DEEGREE_WORKSPACE_ROOT
DEE_DIR="/usr/local/share/deegree/deegree-workspace-utah-light/"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

## start tomcat (and deegree webapps)
cd "$DEE_DIR"
mkdir -p logs
./bin/catalina.sh start

## sleep for 5 sec, due to the tomcat hasn't started yet
sleep 5

## open firefox with deegree 3 console
sudo -u "$USER_NAME" \
   firefox -new-tab http://localhost:8033

