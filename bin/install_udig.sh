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
# This script will install udig 1.2-M6

# Running:
# =======
# udig

cd /usr/lib
wget
gunzip udig-1.2-M6.linux.gtk.x86.tar.gz
tar -xf udig-1.2-M6.linux.gtk.x86.tar

rm udig-1.2-M6.linux.gtk.x86.tar

#In udig.sh replace ./udig_internals with
#DATA_ARG=false
#
#for ARG in $@ 
#do
#        if [ $ARG = "-data" ]; then DATA_ARG=true; fi
#done
#
#if $DATA_ARG; then 
#        /usr/lib/udig/udig_internal $@
#else
#        /usr/lib/udig/udig_internal -data $HOME/uDigWorkspace $@
#fi
mkdir /tmp/udig_downloads/udig-data
cd /tmp/udig_downloads/udig-data
wget http://udig.refractions.net/docs/data-v1_1.zip
unzip data-v1_1.zip
rm data-v1_1.zip
mv -rf /tmp/udig_downloads/udig-data /usr/local/share
rm -rf /tmp/udig_downloads

