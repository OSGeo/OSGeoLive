#!/bin/sh
#################################################
# 
# Purpose: Creating an ISO from an existing system
# Author:  Stefan Hansen <shansen@lisasoft.com>
# Reference: This script is derived from:
#   http://www.debuntu.org/how-to-customize-your-ubuntu-live-cd
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


#The script will create 2 folders in $HOME: work and cd

#export TMP="/tmp"
export TMP="/media/Shorter/repository/livedvd/build-livedvd"
export LIVE_DVD="${TMP}/livedvd" # was WORK
export CD="${TMP}/iso_mount/"
export FORMAT="squashfs"
export FS_DIR="casper"
export VM_ROOT=user@10.0.2.15:/ # The location of the Virtual Machine we will copy
export BASE_ISO="/media/Shorter/repository/downloads/xubuntu-9.04-desktop-i386.iso"

# install appropriate build tools
apt-get install squashfs-tools # chroot

# mount base iso
mkdir ${CD}
mount -o loop ${BASE_ISO} ${CD}

# copy base iso to new live dvd
mkdir ${LIVE_DVD}
mkdir -p ${LIVE_DVD}/rootfs

# now sync with the arramagong virtual machine
rsync -av --one-file-system --exclude=/proc/* --exclude=/dev/*\
 --exclude=/sys/* --exclude=/tmp/* \ #--exclude=/home/*\
 --exclude=/lost+found --exclude=/mnt/* --exclude=/var/www/tmp/*\
 ${VM_ROOT} ${LIVE_DVD}/rootfs

#sudo mkdir -p ${CD}/${FS_DIR} ${CD}/boot/grub ${LIVE_DVD}/rootfs

