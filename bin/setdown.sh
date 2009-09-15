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

# remove build stuff no longer of use
apt-get --yes remove devscripts pbuilder \
   cvs-buildpackage svn-buildpackage \
   lintian debhelper pkg-config

# remove the apt-get cache
apt-get clean

rm -fr \
  /home/user/.bash_history \
  /home/user/.ssh \
  /home/user/.subversion \
  # /tmp/* \

  # Do we need the following:
  # /home/user/.cache \
  # /home/user/.config \
  # /home/user/.dbus \

# Compress image by wiping the vitual disk, filling empty space with zero.
cat /dev/zero > zero.fill ; sync ; sleep 1 ; sync ; rm -f zero.fill

