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
# Authors:
# =======
# Mark Leslie <mark.s.leslie@gmail.com>
# Alex Mandel <tech@wildintellect.com>
# Hamish Bowman <hamish_b yahoo com>
#


POSTGRES_USER="user"
TMP_DIR="/tmp/build_postgis"

if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


### download data
#URL_BASE="ftp://ftp.ardec.com.au/UPLOADS"
#DL_FILE="medford-gisvm.sql.bz2"

# download package is not versioned so we really shouldn't use "wget -c"
#wget -c --progress=dot:mega "$URL_BASE/$DL_FILE"
# -O used to enable auto-overwrite
#wget -nv "$URL_BASE/$DL_FILE.sha1" -O "$DL_FILE.sha1"

#sha1sum --check "$DL_FILE.sha1"
#if [ $? -ne 0 ] ; then
#   echo "ERROR: checksum failed on download"
#   exit 1
#fi


### create DB and populate it
sudo -u $POSTGRES_USER createdb --template=template_postgis osm_local

# simplified the script, was too hard to debug with all the commands
#  attempting to be piped continuously with each other

#bzip2 -d "$DL_FILE"
#sed -i "s/mleslie/$POSTGRES_USER/g" `basename $DL_FILE .bz2`
# use the psql --quiet flag!
#sudo -u $POSTGRES_USER psql --quiet -d barcelona -f `basename $DL_FILE .bz2`

#Now importing data from already downloaded sources (osm)
osm2pgsql -U $POSTGRES_USER -d osm_local -l /tmp/build_osm/Barcelona.osm

#Add additional data sources here, be sparing to minimize duplication of data.
