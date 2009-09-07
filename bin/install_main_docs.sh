#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Copyright (c) 2009 LISAsoft
# Copyright (c) 2009 Cameron Shorter
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
# This script will install documentation from 

# Running:
# =======
# sudo ./install_main_docs.sh

# Requires: nothing

mkdir /usr/share/livedvd-docs/
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/index.html --output-document /usr/share/livedvd-docs/index.html
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/banner.bmp --output-document /usr/share/livedvd-docs/banner.bmp
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/jquery.js --output-document /usr/share/livedvd-docs/jquery.js
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/arramagong.css --output-document /usr/share/livedvd-docs/arramagong.css

# FIXME
echo "install_main_docs.sh FIXME: The Firefox home page shoud be set to file:///usr/share/livedvd-docs/index.html"

