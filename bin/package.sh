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
echo Disk Usage1:, package.sh start, `df | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, package.sh start, `df | grep " /$" | sed -e "s/  */,/g"`, date

echo Disk Usage3:, package.sh start, `df -s ${VM_DIR}/${VM}` , `date`

echo "Start package.sh. Packaging ${VM_DIR}/${VM}"
date

# Install 7zip
apt-get install p7zip-full

echo "Remove non-core VM files, except *.vmx and *.vmdk"
cd "${VM_DIR}/${VM}"

for FILE  in `ls | grep -v "\.vmdk$" | grep -v "\.vmx$"` ; do
  rm -fr $FILE
done

echo Disk Usage3:, after removing non-core VM files, `du -hs ${VM_DIR}/${VM}` , `date`

# Shrink
echo "Shrink the image"
vmware-vdiskmanager -k *.vmdk

echo Disk Usage3:, after shrinking the image, `du -hs ${VM_DIR}/${VM}` , `date`

# Compress
echo "Compress the image using 7z"
cd "${VM_DIR}"
7z a -mx=9 "${PACKAGE_NAME}-${VERSION}.7z" "${PACKAGE_NAME}-${VERSION}" 

echo Disk Usage3:, after 7zipping the image, `du -hs ${PACKAGE_NAME}-${VERSION}.7z` , `date`

# if the image is greater than 2 Gig, we need to split the image, as the OSGeo
# server isn't configured to accept files of a greater size.
# Reconstitute with:
#   `cat ${PACKAGE_NAME}-${VERSION}.7z[1-9]* > ${PACKAGE_NAME}-${VERSION}.7z
echo "Split the image"
split -b 1500M  ${PACKAGE_NAME}-${VERSION}.7z  ${PACKAGE_NAME}-${VERSION}.7z

mv  ${PACKAGE_NAME}-${VERSION}.7z.aa  ${PACKAGE_NAME}-${VERSION}.7z.1
mv  ${PACKAGE_NAME}-${VERSION}.7z.ab  ${PACKAGE_NAME}-${VERSION}.7z.2
mv  ${PACKAGE_NAME}-${VERSION}.7z.ac  ${PACKAGE_NAME}-${VERSION}.7z.3
mv  ${PACKAGE_NAME}-${VERSION}.7z.ad  ${PACKAGE_NAME}-${VERSION}.7z.4
mv  ${PACKAGE_NAME}-${VERSION}.7z.ae  ${PACKAGE_NAME}-${VERSION}.7z.5
mv  ${PACKAGE_NAME}-${VERSION}.7z.af  ${PACKAGE_NAME}-${VERSION}.7z.6

echo "Add the following lines to"
echo "  https://camerons@svn.osgeo.org/osgeo/livedvd/gisvm/trunk/download/index.html"
echo 

echo '<h3>Arramagong GISVM and LiveDVD - ${VERSION}'
echo '<ul>'
for FILE in ${PACKAGE_NAME}-${VERSION}.7z* ; do
  MD5SUM=`md5sum ${FILE}`
  SIZE=`du -h ${FILE} | cut -f1`
  echo '<li>'
  echo '  <a href="${FILE}">$FILE</a>'
  echo '  (${SIZE})'
  echo '  mdsum: $MD5SUM '
  echo '</li>'
done
echo '</ul>'
echo

echo Disk Usage1:, package.sh end, `df | grep "Filesystem" | sed -e "s/  */,/g"`
echo Disk Usage2:, package.sh end, `df | grep " /$" | sed -e "s/  */,/g"`, date
echo Finished package.sh
