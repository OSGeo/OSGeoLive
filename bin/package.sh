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
VERSION=`cat ${DIR}/../VERSION.txt`
PACKAGE_NAME="arramagong-gisvm"
#VM_DIR="/var/lib/vmware/Virtual Machines/" # Default directory
VM_DIR="/mnt/space/arramagong/vm"
VM="arramagong-gisvm-${VERSION}"

echo "===================================================================="
echo "Starting package.sh for version: {$VERSION}"
echo "===================================================================="
echo Disk Usage1:, package.sh start, `df | grep "Filesystem" | sed -e "s/  */,/g"`
echo Disk Usage2:, package.sh start, `df | grep " /$" | sed -e "s/  */,/g"`
echo "Start package.sh. Packaging ${VM_DIR}/${VM}"
date

# Install 7zip
apt-get install p7zip-full

# Remove non-core VM files, except *.vmx and *.vmdk
cd "${VM_DIR}/${VM}"

for FILE  in `ls | grep -v "\.vmdk$" | grep -v "\.vmx$"` ; do
  rm -fr $FILE
done


# Shrink
echo "Shrink the image"
vmware-vdiskmanager -k *.vmdk

# Compress
echo "Compress the image using 7z"
cd "${VM_DIR}"
pwd
7z a -mx=9 "${PACKAGE_NAME}-${VERSION}.7z" "${PACKAGE_NAME}-${VERSION}" 

# if the image is greater than 2 Gig, we need to split the image, as the OSGeo
# server isn't configured to accept files of a greater size.
# Reconstitute with:
#   `cat ${PACKAGE_NAME}-${VERSION}.7z[1-9]* > ${PACKAGE_NAME}-${VERSION}.7z
echo "Split the image"
split -b 1500M  ${PACKAGE_NAME}-${VERSION}.7z  ${PACKAGE_NAME}-${VERSION}.7z

# Checksums
echo "Create checksums"
md5sum ${PACKAGE_NAME}-${VERSION}*.7z*

echo Disk Usage1:, package.sh end, `df | grep "Filesystem" | sed -e "s/  */,/g"`
echo Disk Usage2:, package.sh end, `df | grep " /$" | sed -e "s/  */,/g"`
echo Finished package.sh
date
