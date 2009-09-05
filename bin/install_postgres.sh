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
# This script will install postgres 8.3, postgis and pgadmin3

# Running:
# =======
# sudo /etc/init.d/postgresql-8.3 start

apt-get install postgresql-8.3-postgis pgadmin3

#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER

#include pgadmin3 profile for connection
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/postgis-conf/pgadmin3 \
  --output-document=~/.pgadmin3
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/postgis-conf/pgpass \
  --output-document=~/.pgpass
