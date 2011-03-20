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
# This script provides the steps to be run on the LiveDVD in order to get the
# install scripts onto the LiveDVD, and start installing.
# For detailed build instructions, refer to:
#   http://wiki.osgeo.org/wiki/GISVM_Build#Creating_a_fresh_Virtual_Machine


# Running:
# =======
# sudo ./boostrap.sh

SCRIPT_DIR=/usr/local/share

# copy in pre-downloaded data files. flavour to suit or just skip 
# rsync -avz cshorter@192.168.2.166::/media/Shorter/repository/livedvd/Arramagong_tmp/ /tmp/

apt-get --assume-yes install subversion

# check out the install scripts from subversion
cd $SCRIPT_DIR

# Use "svn export" instead of "svn checkout" to save space by not having the
#   cached .svn/ files stored locally
#svn export http://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_4_5 gisvm

svn checkout http://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_4_5 gisvm
chown -R user:user gisvm
cd /home/user
ln -s ${SCRIPT_DIR}/gisvm .

# make a directory for the install logs
mkdir /var/log/osgeolive/

# FIXME: a+w is to be avoided always!
chmod a+wr /var/log/osgeolive/


echo "If you have a local copy if the tmp/ directory and wish to"
echo "save bandwidth, then copy it across to your DVD now, using a"
echo "command like:"
echo "  rsync -avz username@hostname.org:/path_to_tmp_dir/ /tmp/"
echo "  rsync -avz username@hostname.org:/path_to_tmp_apt_dir/ /var/cache/apt/"
