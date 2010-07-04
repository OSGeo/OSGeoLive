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
# This script will install sun jre 6 and jdk 6

add-apt-repository "deb http://archive.canonical.com/ lucid partner"
apt-get update

apt-get --assume-yes remove openjdk-6-jre
### wtf? why is the above removing the unrelated pdftk??
apt-get --assume-yes install pdftk

apt-get --assume-yes install java-common sun-java6-bin sun-java6-jre sun-java6-jdk


