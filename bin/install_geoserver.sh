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
# This script will install Geoserver 1.7

# Requires: tomcat6

# Configuration:
# add this before the last "};":
# permission java.security.AllPermission;
# to /etc/tomcat6/policy.d/04webapps.policy

mkdir /tmp/gs-download
cd /tmp/gs-download
wget http://downloads.sourceforge.net/geoserver/geoserver-1.7.6-war.zip
unzip geoserver-1.7.6-war.zip

#deploy geoserver-1.7.6-war through the html-interface
