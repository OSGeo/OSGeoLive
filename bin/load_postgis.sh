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



export postgres_user=mleslie
export return_pwd=`pwd`
wget "ftp://ftp.ardec.com.au/UPLOADS/medford-gisvm.sql.bz2" --output-document="/tmp/medford-gisvm.sql.bz2"
wget "ftp://ftp.ardec.com.au/UPLOADS/medford-gisvm.sql.bz2.sha1" --output-document="/tmp/medford-gisvm.sql.bz2.sha1"
cd /tmp

sha1sum --check medford-gisvm.sql.bz2.sha1 && \
(
  createdb -U $postgres_user --template=template_postgis medford && \
  (
    bzip2 -dc /tmp/medford-gisvm.sql.bz2 | psql -U $postgres_user medford > /dev/null || \
    (
      echo ** Data load failure.  Cleaning up. **
      dropdb -U $postgres_user medford
    )
  ) \
  || \
  (
    echo ** Database creation error. **
  )
) \
|| \
(
  echo ** Invalid data package. **
)

rm /tmp/medford-gisvm.sql.bz2 /tmp/medford-gisvm.sql.bz2.sha1

cd $return_pwd

