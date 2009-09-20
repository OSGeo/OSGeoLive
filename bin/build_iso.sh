#!/bin/sh
#################################################
# 
# Purpose: Creating an ISO from an existing system
# Author:  Stefan Hansen
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

# This script is expected to be run as root inside the arramagong LiveDVD
# after it has been installed. See README is this directory
# for instuctions.
#
#   sudo build_iso.sh


cd $HOME

WORK=/tmp/work
CD=/tmp/cd
FORMAT=squashfs
FS_DIR=casper

# do any of these really need to be exported from the script?
export WORK CD FORMAT FS_DIR


mkdir -p ${CD}/${FS_DIR} ${CD}/boot/grub ${WORK}/rootfs

# update the system and install required packages
# apt-get update
apt-get install mkisofs grub squashfs-tools syslinux sbm
apt-get install linux-ubuntu-modules-$(uname -r)
apt-get clean

# rsync with /
rsync -av --one-file-system --exclude=/proc/* --exclude=/dev/*\
 --exclude=/sys/* --exclude=/tmp/* --exclude=/home/*\
 --exclude=/lost+found --exclude=/mnt/* --exclude=/var/www/tmp/*\
 / ${WORK}/rootfs

cp -av /boot/* ${WORK}/rootfs/boot

#stuff we need from $HOME
# CONFIG='.config .bashrc .qgis uDigWorkspace welcome Desktop gvSIG .eclipse .pgadmin3 qgisDemo.qgs alaska.gvp .grassrc6'

#cd $HOME && for i in $CONFIG
#do
echo cp -rp --parents * ${WORK}/rootfs/etc/skel
cp -rp --parents * ${WORK}/rootfs/etc/skel
#done

# cp the script we need to run in chroot 
wget https://svn.osgeo.org/osgeo/livedvd/scripts/trunk/LiveDVDFromScratch/inchroot.sh
mv inchroot.sh $WORK/rootfs/tmp/
chmod a+x $WORK/rootfs/tmp/inchroot.sh

# mount proc and dev into work
mount -o bind /dev/ ${WORK}/rootfs/dev
mount -t proc proc ${WORK}/rootfs/proc

#get into chroot and execute the inchroot.sh
chroot ${WORK}/rootfs /tmp/inchroot.sh

#########################################################
# The following is derived from Stefan's iso2.sh script
#########################################################

cd $HOME
#export WORK=/tmp/work
#export CD=/tmp/cd
#export FORMAT=squashfs
#export FS_DIR=casper
export IMAGE_VERSION=Alpha5

#Copy the kernel, the updated initrd
sudo cp -vp ${WORK}/rootfs/boot/vmlinuz-$(uname -r) ${CD}/casper/vmlinuz
sudo cp -vp ${WORK}/rootfs/boot/initrd.img-$(uname -r) ${CD}/casper/initrd.gz

# Only used if ubiquity is installed
#sudo chroot ${WORK}/rootfs dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee ${CD}/${FS_DIR}/filesystem.manifest

#sudo cp -v ${CD}/${FS_DIR}/filesystem.manifest ${CD}/${FS_DIR}/filesystem.manifest-desktop

#REMOVE='ubiquity casper user-setup discover1 xresprobe os-prober libdebian-installer4'

#for i in $REMOVE 
#do
#	sudo sed -i "/${i}/d" ${CD}/${FS_DIR}/filesystem.manifest-desktop
#done

#unmount things we mounted before
sudo umount ${WORK}/rootfs/proc
sudo umount ${WORK}/rootfs/sys
sudo umount ${WORK}/rootfs/dev

#create the squashed fs from the directory tree in $CD
sudo mksquashfs ${WORK}/rootfs ${CD}/${FS_DIR}/filesystem.${FORMAT} -noappend -no-duplicates

sudo mkdir ${CD}/isolinux
sudo cp /usr/lib/syslinux/isolinux.bin ${CD}/isolinux/

sudo mkdir ${CD}/install
sudo mkdir ${CD}/install/memtest
sudo cp /boot/memtest86+.bin ${CD}/install/memtest
sudo cp /boot/sbm.img ${CD}/install/

sudo rm -rf ${CD}/boot

#Copy your win installer into $CD/win!!!!! and isolinux-config into $CD/isolinux. An example can be found in the addcd-folder of the svn 

#make the iso
cd $CD && find . -type f -print0 | xargs -0 sudo md5sum | sudo tee ${CD}/md5sum.txt

sudo mkisofs -r -V "Arramagong_v$IMAGE_VERSION" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o /tmp/Arramagong_v$IMAGE_VERSION.iso .

