#!/bin/bash
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
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
# This script will install osgearth in xubuntu
#
# osgEarth is a scalable terrain rendering toolkit for OpenSceneGraph
# http://osgearth.org/

./diskspace_probe.sh "`basename $0`" begin
####


#install using an official backport jul13

apt-get -q update
apt-get install --assume-yes ipython-notebook  -t precise-backports

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

####
./diskspace_probe.sh "`basename $0`" end
