#!/bin/sh
# Copyright (c) 2011 The Open Source Geospatial Foundation.
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
# This script will install openjdk version 7

TMP="/tmp/build_openjdk"

mkdir -p "$TMP"
cd "$TMP"

# Download and uncompress openjdk
wget -c --progress=dot:mega http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-i586.tar.gz
tar -zxvf jdk-7-linux-i586.tar.gz

# Move JDK 7 directory to place where it should be. Right, to the /usr/lib/jvm/jdk1.7.0 directory. Use this command for that
mkdir -p /usr/lib/jvm
mv ./jdk1.7.0/ /usr/lib/jvm/jdk1.7.0
