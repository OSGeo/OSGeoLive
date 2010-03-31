#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will cleanup the system after running GISVM install scripts.

# Running:
# =======
# sudo ./setdown.sh 2>&1 | tee /var/log/arramagong/setdown.log

DIR=`dirname ${0}`
VERSION=`cat ${DIR}/../VERSION.txt`
PACKAGE_NAME="arramagong-gisvm"
VM="${PACKAGE_NAME}-${VERSION}"


# remove build stuff no longer of use
apt-get --yes remove devscripts pbuilder \
   cvs-buildpackage svn-buildpackage \
   lintian debhelper pkg-config

# Copy tmp files, apt cache and logs ready for backup
mkdir /tmp/${VERSION}
cd /tmp/${VERSION}

mkdir ${VM}-tmp
mv /tmp/build* ${VM}-tmp
mv /tmp/*downloads ${VM}-tmp

ln -s /var/cache/apt/ ${VM}-apt-cache
ln -s /var/log/arramagong/ ${VM}-log

# remove the apt-get cache
apt-get clean

rm -fr \
  /home/user/.bash_history \
  /home/user/.ssh \
  /home/user/.subversion \
  # /tmp/* \ # tmp is cleared during shutdown

  # Do we need the following:
  # /home/user/.cache \
  # /home/user/.config \
  # /home/user/.dbus \


# clean out ssh keys which should be machine-unique
rm -f /etc/ssh/ssh_host_[rd]sa_key
# change a stupid sshd default
sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config


echo "==============================================================="
echo " Compress image by wiping the virtual disk, filling empty space with zero."
cat /dev/zero > zero.fill ; sync ; sleep 1 ; sync ; rm -f zero.fill

echo "==============================================================="
echo "Finished setdown.sh. Copy backup files and logs to the host system with:"
echo "scp -pr /tmp/${VERSION} username@hostname:/directory"
