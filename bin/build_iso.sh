#!/bin/sh
#################################################
# 
# Purpose: Creating an ISO from an existing system
# Author:  Stefan Hansen <shansen@lisasoft.com>
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

# This script is expected to be run as root. See README is this directory
# for instuctions.
#   sudo iso1.sh


cd $HOME

export WORK=/tmp/work
export CD=/tmp/cd
export FORMAT=squashfs
export FS_DIR=casper

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

# cp the script we nee to run in chroot 
wget https://svn.osgeo.org/osgeo/livedvd/scripts/trunk/LiveDVDFromScratch/inchroot.sh
mv inchroot.sh $WORK/rootfs/tmp/

# mount proc and dev into work
mount -o bind /dev/ ${WORK}/rootfs/dev
mount -t proc proc ${WORK}/rootfs/proc

#get into chroot
chroot ${WORK}/rootfs /bin/bash

# continue with running inchroot.sh and then exit chroot...
