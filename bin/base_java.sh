#!/bin/sh
#############################################################################
#
# Purpose: This script will install Jave JRE and Java JDK
#
#############################################################################
# Copyright (c) 2009-2021 Open Source Geospatial Foundation (OSGeo) and others.
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

./diskspace_probe.sh "`basename $0`" begin
####

# NOTE: We have changed the java-common package in our ppa to point default-jdk to openjdk-8
apt-get install --yes default-jdk default-jre

apt-get install --yes gsfonts-x11 ttf-dejavu-extra

####
./diskspace_probe.sh "`basename $0`" end
