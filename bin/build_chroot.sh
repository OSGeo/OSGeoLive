#!/bin/sh
#################################################
# 
# Purpose: Creating OSGeoLive as an Ubuntu customization
# 	   https://help.ubuntu.com/community/LiveCDCustomization
# Authors: Alex Mandel <tech_dev@wildintellect.com>
#	   Angelos Tzotsos <tzotsos@gmail.com>
#
#################################################
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
##################################################

#DIR=`dirname ${0}`
#VERSION=`cat "$DIR"/../VERSION.txt`
VERSION="6.0beta7"
PACKAGE_NAME="osgeo-live"
ISO_NAME="${PACKAGE_NAME}-${VERSION}"

sudo apt-get install squashfs-tools genisoimage

#TODO add wget to grab a fresh image, optional

#Stuff to be done the 1st time, should already be in place for additional builds
mkdir ~/livecdtmp
cd ~/livecdtmp
#mv ubuntu-9.04-desktop-i386.iso ~/livecdtmp
wget http://se.archive.ubuntu.com/mirror/cdimage.ubuntu.com/xubuntu/releases/12.04/release/xubuntu-12.04-desktop-i386.iso
#mv xubuntu-10.04-desktop-i386.iso ~/livecdtmps

mkdir mnt

#Start with a fresh copy
sudo mount -o loop xubuntu-12.04-desktop-i386.iso mnt

mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

sudo unsquashfs mnt/casper/filesystem.squashfs
#Does the above need to be done every time or can it be done once, and then just make a fresh copy of the chroot for each builds
sudo mv squashfs-root edit

sudo cp /etc/resolv.conf edit/etc/
sudo cp /etc/hosts edit/etc/

sudo mount --bind /dev/ edit/dev
sudo chroot edit
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

export HOME=/roots
export LC_ALL=C


dbus-uuidgen > /var/lib/dbus/machines-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#Execute the build
cd /tmp/
wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/bin/bootstrap.sh
chmod a+x bootstrap.sh
./bootstrap.sh
cd /usr/local/share/gisvm
svn update -r 8413
cd bin
./main.sh 2>&1 | tee /var/log/osgeolive/main_install.log

#After the build
#Check for users above 999
awk -F: '$3 > 999' /etc/passwd

#Cleanup
apt-get clean
rm -rf /tmp/* ~/.bash_history
rm /etc/hosts
rm /etc/resolv.conf
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit
sudo umount edit/dev
tar czf osgeo-live-${VERSION}-log.tar.gz -C edit/var/log osgeolive

#remaster the dvd
chmod +w extract-cd/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop

sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs

#Update the filesystem.size file, which is needed by the installer:
# TODO: get it to run as sudo no sudo su
chmod +w extract-cd/casper/filesystem.size
printf $(sudo du -sx --block-size=1 edit | cut -f1) > extract-cd/casper/filesystem.size
chmod -w extract-cd/casper/filesystem.size
cd ~/livecdtmp
sudo rm -rf edit

#Set an image name in extract-cd/README.diskdefines
#KVM VNC doesn't pass ctrl, can't use vim or nano
#Can probably use sed magic
sudo nano extract-cd/README.diskdefines

#Remove old md5sum.txt and calculate new md5 sums
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | grep -v isolinux/boot.cat | sudo tee md5sum.txt

#Create the ISO image
sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../osgeo-live-${version}-mini.iso .
