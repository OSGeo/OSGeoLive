#!/bin/sh
#############################################################################
# 
# Purpose: Creating OSGeoLive as an Ubuntu customization
# 	   https://help.ubuntu.com/community/LiveCDCustomization
# Authors: Alex Mandel <tech_dev@wildintellect.com>
#	   Angelos Tzotsos <tzotsos@gmail.com>
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
#     1. At least 3-5 GB of free space
#     2. At least 512 MB RAM and 1 GB swap (recommended)
#     3. squashfs-tools
#     4. genisoimage, which provides mkisofs
#     5. An Ubuntu kernel with squashfs support (present in Ubuntu 6.06 and later)
#     6. QEMU/KVM, VirtualBox or VMware for testing (optional) 
#

DIR="/home/user/gisvm/bin"
VERSION=`cat "$DIR"/../VERSION.txt`
PACKAGE_NAME="osgeo-live"
ISO_NAME="${PACKAGE_NAME}-${VERSION}"

sudo apt-get install squashfs-tools genisoimage

#TODO add wget to grab a fresh image, optional

#Stuff to be done the 1st time, should already be in place for additional builds
#Download into an empty directory 
mkdir ~/livecdtmp
cd ~/livecdtmp
#mv ubuntu-9.04-desktop-i386.iso ~/livecdtmp
wget -c http://se.archive.ubuntu.com/mirror/cdimage.ubuntu.com/xubuntu/releases/12.04/release/xubuntu-12.04-desktop-i386.iso

#Start with a fresh copy
#Mount the Desktop .iso
mkdir mnt
sudo mount -o loop xubuntu-12.04-desktop-i386.iso mnt

#Extract .iso contents into dir 'extract-cd' 
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

#Extract the SquashFS filesystem 
sudo unsquashfs mnt/casper/filesystem.squashfs
#Does the above need to be done every time or can it be done once, and then just make a fresh copy of the chroot for each builds
sudo mv squashfs-root edit

#If you need the network connection within chroot 
sudo cp /etc/resolv.conf edit/etc/
sudo cp /etc/hosts edit/etc/

#These mount important directories of your host system - if you later decide to delete the edit/ directory,
#then make sure to unmount before doing so, otherwise your host system will become unusable at least 
#temporarily until reboot
sudo mount --bind /dev/ edit/dev
#NOW IN CHROOT
#sudo chroot edit

sudo cp "$DIR"/inchroot.sh ~/livecdtmp/edit/tmp/
sudo chroot edit /bin/sh /tmp/inchroot.sh

#exit
#OUT OF CHROOT
cd ~/livecdtmp
sudo umount edit/dev

#compress osgeolive build logs
tar czf osgeo-live-${VERSION}-log.tar.gz -C edit/var/log osgeolive

#remaster the dvd
#Regenerate manifest 
chmod +w extract-cd/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
#Compress filesystem
sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs

#Update the filesystem.size file, which is needed by the installer:
# TODO: get it to run as sudo no sudo su
chmod +w extract-cd/casper/filesystem.size
printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size
chmod -w extract-cd/casper/filesystem.size

#this is now compressed in squashfs so we delete to save VM disk space
cd ~/livecdtmp
sudo rm -rf edit

#Set an image name in extract-cd/README.diskdefines
#KVM VNC doesn't pass ctrl, can't use vim or nano
#Can probably use sed magic or copy a predefined file from gisvm/app-data
sudo nano extract-cd/README.diskdefines

#Remove old md5sum.txt and calculate new md5 sums
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

#Create the ISO image
sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../osgeo-live-${version}-mini.iso .
