#!/bin/sh
#################################################
# 
# Purpose: Compress and package the Arramagong / GISVM images
# Author:  Cameron Shorter
#
#################################################
# Copyright (c) 2009 Open Geospatial Foundation
# Copyright (c) 2009 LISAsoft
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
##################################################

# Prerequisites:
# * Running an Ubuntu or Ubuntu derivative system
# * VMWare Server is installed
# * 
# Running:
# =======
# 

DIR=`dirname ${0}`
VERSION=cat ${DIR}/VERSION.txt
PACKAGE_NAME="arramagong-gisvm"
VM_DIR="/var/lib/vmware/Virtual Machines/" # Default directory
VM="arramagong-gisvm-2.0-alpha5"

# Remove non-core VM files, except *.vmx and *.vmdk
cd ${VM_DIR}${VM}
for FILE  in `ls | grep -v "\.vmdk$" | grep -v "\.vmx$"` ; do
  rm $FILE
done

# Shrink image
vmware-vdiskmanager -k *.vmdk

# Compress the image using 7z
cd $VM_DIR
7z a -mx=9 "${PACKAGE_NAME}-{VERSION}.7z" ${VM_DIR}

