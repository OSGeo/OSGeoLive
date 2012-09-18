#!/bin/sh
#############################################################################
# 
# Purpose: Creating OSGeoLive as an Ubuntu customization
# 	   https://help.ubuntu.com/community/LiveCDCustomization
# Authors: Alex Mandel <tech_dev@wildintellect.com>
#
#
#############################################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
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

# System Requirements
#
#     1. At least 10 GB of free space
#     2. At least 512 MB RAM and 1 GB swap (recommended)
#     4. genisoimage, which provides mkisofs
#     6. QEMU/KVM, VirtualBox or VMware for testing (optional) 
#
# Checkout a copy of the svn, change to the bin folder
# Run as 
# sudo ./build_full_iso.sh /path/to/file.iso 2>&1 | tee ~/build_full_iso.log
# Expects 1 argument, the path to the mini iso

#DIR="/home/user/gisvm/bin"
#SVN_DIR="/home/user/gisvm"
VERSION=`cat ../VERSION.txt`
PACKAGE_NAME="osgeo-live"
#cd "$SVN_DIR"
#REVISION=`svn info | grep "Revision" | sed 's/Revision: //'`
CUR_DIR=`pwd`

if [ $1 ]; then
    #If argument is given, path to the iso to remaster
    MINI_ISO_NAME=$1
else
    #If no arguement is give assume the file is in the current folder
    MINI_ISO_NAME="$PACKAGE_NAME-mini-$VERSION.iso"
fi
ISO_NAME="$PACKAGE_NAME-$VERSION"

echo
echo "Installing genisoimage"
echo "==================================="

sudo apt-get install genisoimage


echo
echo "Extract mini iso"
echo "==================================="

mkdir -p ~/livecdtmp
cd ~/livecdtmp

#Start with a fresh copy
#Mount the Desktop .iso to mnt2 to not interfere with other builds
mkdir mnt2
sudo mount -o loop "$MINI_ISO_NAME" mnt2

#Extract .iso contents into dir 'extract-cd' 
mkdir "extract-cd"
rsync -a mnt2/ "extract-cd"

echo
echo "Download Windows and Mac Installers"
echo "==================================="

cd extract-cd
sh $CUR_DIR/load_win_installers.sh
sh $CUR_DIR/load_mac_installers.sh
cd ..

echo
echo "Regenerating manifest..."
echo "======================================"
#Regenerate manifest 
#chmod +w extract-cd/casper/filesystem.manifest
#sudo cp extract-cd/casper/filesystem.manifest \
#   extract-cd/casper/filesystem.manifest-desktop
#sudo sed -i '/ubiquity/d' \
#   extract-cd/casper/filesystem.manifest-desktop
#sudo sed -i '/casper/d' \
#   extract-cd/casper/filesystem.manifest-desktop

echo
echo "Calculating new filesystem size..."
echo "======================================"
#Update the filesystem.size file, which is needed by the installer:
# TODO: get it to run as sudo no sudo su
#chmod +w extract-cd/casper/filesystem.size
#printf $(sudo du -sx --block-size=1 edit | cut -f1) > \
#   extract-cd/casper/filesystem.size
#chmod -w extract-cd/casper/filesystem.size


echo
echo "Calculating new md5 sums..."
echo "======================================"
#Remove old md5sum.txt and calculate new md5 sums
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | \
   grep -v isolinux/boot.cat | sudo tee md5sum.txt

echo
echo "Creating iso..."
echo "======================================"
#Create the ISO image
sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b \
   isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
   -boot-load-size 4 -boot-info-table -o ../"$ISO_NAME.iso" .

echo
echo "Cleaning up..."
echo "======================================"
#Clear things up and prepare for next build
cd ~/livecdtmp
sudo rm -rf extract-cd
sudo umount mnt2
sudo rm -rf mnt2

