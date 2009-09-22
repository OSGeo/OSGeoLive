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

#export WORK=/tmp/work
#export CD=/tmp/cd
#export FORMAT=squashfs
#export FS_DIR=casper

LANG=

echo start inchroot.sh, `date`

# update the system and install required packages
#apt-get update
apt-get install casper xresprobe 
#apt-get ubiquity
depmod -a $(uname -r)

echo "update the initramfs"
update-initramfs -u -k $(uname -r)

#delete all the things we don't need and clean up
echo remove unrequired directories
for i in "/etc/hosts /etc/hostname /etc/resolv.conf /etc/timezone /etc/fstab /etc/mtab /etc/shadow /etc/shadow- /etc/gshadow  /etc/gshadow- /etc/gdm/gdm-cdd.conf /etc/gdm/gdm.conf-custom /etc/X11/xorg.conf /boot/grub/menu.lst /boot/grub/device.map"
do
  rm $i
done

apt-get clean
rm -r /tmp/* /root/*
rm  /boot/*.bak

for i in `cat /etc/passwd | awk -F":" '{print $1}'`
do
  uid=`cat /etc/passwd | grep "^${i}:" | awk -F":" '{print $3}'`
  [ "$uid" -gt "999" -a  "$uid" -ne "65534"  ] && userdel --force ${i} 2>/dev/null
done

find /var/run /var/log /var/mail /var/spool /var/lock /var/backups /var/tmp -type f -exec rm {} \;

[ -f "/etc/gdm/factory-gdm.conf" ] && cp -f /etc/gdm/factory-gdm.conf /etc/gdm/gdm.conf 2>/dev/null

for i in dpkg.log lastlog mail.log syslog auth.log daemon.log faillog lpr.log mail.warn user.log boot debug mail.err messages wtmp bootstrap.log dmesg kern.log mail.info
do
  touch /var/log/${i}
done

echo finished inchroot.sh, `date`
