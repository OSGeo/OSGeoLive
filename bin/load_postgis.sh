#!/bin/sh
# Copyright (c) 2009 Mark Leslie
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
#
# About:
# =====
# This script will is to be run after the installation of postgresql 
# and postgis.  It will download, validate and load a simple dataset.
#
# Author:
# ======
# Mark Leslie <mark.s.leslie@gmail.com>
# Alex Mandel <tech@wildintellect.com>



export postgres_user=user
export return_pwd=`pwd`

# download package is not versioned so we don't use "wget -c"
wget --progress=dot:mega \
   "ftp://ftp.ardec.com.au/UPLOADS/medford-gisvm.sql.bz2" \
   --output-document="/tmp/medford-gisvm.sql.bz2"
wget -nv "ftp://ftp.ardec.com.au/UPLOADS/medford-gisvm.sql.bz2.sha1" \
   --output-document="/tmp/medford-gisvm.sql.bz2.sha1"

cd /tmp

sha1sum --check medford-gisvm.sql.bz2.sha1
# wanted?
# if [ $? -ne 0 ] ; then
#   echo "ERROR: checksum failed on download"
#   exit 1
# fi

sudo -u $postgres_user createdb --template=template_postgis medford

# simplified the script, was too hard to debug with all the commands
#  attempting to be piped continuously with each other

bzip2 -d /tmp/medford-gisvm.sql.bz2 
sed -i "s/mleslie/$postgres_user/g" /tmp/medford-gisvm.sql
sudo -u $postgres_user psql medford -f /tmp/medford-gisvm.sql

#Not neeeded since the /tmp will be wiped on reboot and not included in the iso
#rm /tmp/medford-gisvm.sql.bz2 /tmp/medford-gisvm.sql.bz2.sha1

cd $return_pwd
