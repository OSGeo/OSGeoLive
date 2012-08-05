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
SVN_DIR="/home/user/gisvm"
VERSION=`cat "$DIR"/../VERSION.txt`
PACKAGE_NAME="osgeo-live"
cd $SVN_DIR
REVISION=`svn info | grep "Revision" | sed 's/Revision: //'`

#Is it a public or an internal build?
#ISO_NAME="$PACKAGE_NAME-$VERSION"
ISO_NAME="$PACKAGE_NAME-mini-build$REVISION"

echo
echo "==============================================================="
echo "Start Building $ISO_NAME"
echo "==============================================================="

#Some initial cleaning
rm -rf ~/livecdtmp/edit

echo
echo "Installing squashfs and genisoimage"
echo "==================================="

sudo apt-get install squashfs-tools genisoimage lzip

#TODO add wget to grab a fresh image, optional

echo
echo "Downloading Xubuntu original image..."
echo "====================================="

#Stuff to be done the 1st time, should already be in place for additional builds
#Download into an empty directory 
mkdir -p ~/livecdtmp
cd ~/livecdtmp
#mv ubuntu-9.04-desktop-i386.iso ~/livecdtmp
wget -c http://se.archive.ubuntu.com/mirror/cdimage.ubuntu.com/xubuntu/releases/12.04/release/xubuntu-12.04-desktop-i386.iso

#Start with a fresh copy
#Mount the Desktop .iso
mkdir mnt
sudo mount -o loop xubuntu-12.04-desktop-i386.iso mnt
echo "Xubuntu image mounted."

#Extract .iso contents into dir 'extract-cd' 
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

echo
echo "Extracting squashfs from Xubuntu image"
echo "======================================"
#Extract the SquashFS filesystem 
sudo unsquashfs mnt/casper/filesystem.squashfs
#Does the above need to be done every time or can it be done once, and then just make a fresh copy of the chroot for each builds
sudo mv squashfs-root edit

echo
echo "Setting up network for chroot"
echo "======================================"
#If you need the network connection within chroot 
sudo cp /etc/resolv.conf edit/etc/
sudo cp /etc/hosts edit/etc/

#These mount important directories of your host system - if you later decide to delete the edit/ directory,
#then make sure to unmount before doing so, otherwise your host system will become unusable at least 
#temporarily until reboot
sudo mount --bind /dev/ edit/dev

echo
echo "Starting build in chroot"
echo "======================================"

#NOW IN CHROOT
#sudo chroot edit
sudo cp "$DIR"/inchroot.sh ~/livecdtmp/edit/tmp/
sudo cp "$SVN_DIR"/VERSION.txt ~/livecdtmp/edit/tmp/
sudo cp "$SVN_DIR"/CHANGES.txt ~/livecdtmp/edit/tmp/
sudo chroot edit /bin/sh /tmp/inchroot.sh

#exit
#OUT OF CHROOT
echo
echo "Finished chroot part"
echo "======================================"
cd ~/livecdtmp
sudo umount edit/dev

#compress osgeolive build logs
#tar czf osgeo-live-${VERSION}-log.tar.gz -C edit/var/log osgeolive

echo
echo "Remastering the dvd..."
echo "======================================"
#remaster the dvd

#Method 1 requires that dist-upgrade is run on both the host and chroot
#need to make sure modules.dep exists for the current kernel before next step
#sudo depmod
#sudo chroot edit depmod
#sudo chroot edit mkinitramfs -c lzma -o /initrd.lz

#Method 2 hardcode default kernel from xubuntu
#need to repack the initrd.lz to pick up the change to casper.conf and kernel update
sudo chroot edit mkinitramfs -c lzma -o /initrd.lz 3.2.0-23-generic

#continue
mkdir lzfiles
cd lzfiles
lzma -dc -S .lz ../edit/initrd.lz | cpio -imvd --no-absolute-filenames
cp ../../gisvm/app-conf/casper.conf etc/casper.conf
#replace the user password, potentially also set backgrounds here
sed -i -e 's/U6aMy0wojraho/eLyJdzDtonrIc/g' scripts/casper-bottom/25adduser
#Change the text on the loader
sed -i -e 's/title=Xubuntu 12.04/title=OSGeo-Live ${VERSION}/g' lib/plymouth/themes/xubuntu-text/xubuntu-text.plymouth
#copy in a different background
cp ../../gisvm/desktop-conf/osgeo-desktop.png lib/plymouth/themes/xubuntu-logo/xubuntu-greybird.png
find . | cpio --quiet --dereference -o -H newc | lzma -7 > ../extract-cd/casper/initrd.lz
#sudo cp edit/initrd.lz extract-cd/casper/initrd.lz
cd ..

echo
echo "Regenerating manifest..."
echo "======================================"
#Regenerate manifest 
chmod +w extract-cd/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

echo
echo "Compressing filesystem..."
echo "======================================"
#Compress filesystem
sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs

echo
echo "Calculating new filesystem size..."
echo "======================================"
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
#sudo nano extract-cd/README.diskdefines
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/README.diskdefines \
     --output-document=extract-cd/README.diskdefines

echo
echo "Calculating new md5 sums..."
echo "======================================"
#Remove old md5sum.txt and calculate new md5 sums
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

echo
echo "Creating iso..."
echo "======================================"
#Create the ISO image
sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../"${ISO_NAME}.iso" .

echo
echo "Cleaning up..."
echo "======================================"
#Clear things up and prepare for next build
cd ~/livecdtmp
sudo rm -rf extract-cd
sudo umount mnt
sudo rm -rf mnt

echo
echo "==============================================================="
echo "Finished building $ISO_NAME"
echo "==============================================================="
