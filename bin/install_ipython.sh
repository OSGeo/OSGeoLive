#!/bin/sh
# Copyright (c) 2013 The Open Source Geospatial Foundation.
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
# This script will install ipython and ipython-notebook in ubuntu
# The future may hold interesting graphical examples using notebook + tools

./diskspace_probe.sh "`basename $0`" begin
####

echo "deb http://archive.ubuntu.com/ubuntu precise-backports main restricted universe" \
      | sudo tee /etc/apt/sources.list.d/backports.list

apt-get update

apt-get install --assume-yes ipython-notebook -t precise-backports

sudo rm -f /etc/apt/sources.list.d/backports.list

apt-get update

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi



####
./diskspace_probe.sh "`basename $0`" end
