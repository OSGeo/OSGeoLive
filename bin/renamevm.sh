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
# Copy a vmware image to a new name. This is a helper script to be run manually when managing virtual machines.
# needs to be run as sudo
# Command line args, original dir, new dir
orig=$1
new=$2
cp -R $1 $2
cd $2
#Quick way to rename the files
mv ${orig}.vmx ${new}.vmx
mv ${orig}.vmdk ${new}.vmdk
mv ${orig}.vmxf ${new}.vmxf
mv ${orig}.vmsd ${new}.vmsd
mv ${orig}.nvram ${new}.nvram

#replace names in vmx file to link to the new names
sed -i "s/${orig}/${new}/g" ${new}.vmx
