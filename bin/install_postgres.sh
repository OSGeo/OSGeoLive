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

USER_NAME="user"

apt-get install --yes postgresql-8.3-postgis pgadmin3 libgeos-dev

#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER_NAME

echo "alter role \"user\" with password 'user'" > /tmp/build_postgre.sql
sudo -u postgres psql -f /tmp/build_postgre.sql
# rm /tmp/build_postgre.sql

#configure template postgis database
sudo -u $USER_NAME createdb template_postgis 
sudo -u $USER_NAME createlang plpgsql template_postgis 
sudo -u $USER_NAME psql -d template_postgis  -f /usr/share/postgresql-8.3-postgis/lwpostgis.sql 
sudo -u $USER_NAME psql -d template_postgis  -f /usr/share/postgresql-8.3-postgis/spatial_ref_sys.sql 

#include pgadmin3 profile for connection
for FILE in  pgadmin3  pgpass  ; do
   wget -nv "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/postgis-conf/$FILE" \
      --output-document="/home/$USER_NAME/.$FILE"

    chown $USER_NAME:$USER_NAME "/home/$USER_NAME/.$FILE"
    chmod 600 "/home/$USER_NAME/.$FILE"
done


#add a connection for qgis if it's installed
QGIS_CONFIG="/home/$USER_NAME/.config/QuantumGIS/QGIS.conf"
if [ -e "$QGIS_CONFIG" ] && \
   [ `grep -c '\[PostgreSQL\]' "$QGIS_CONFIG"` -eq 0 ] ; then
	cat >> "/home/$USER_NAME/.config/QuantumGIS/QGIS.conf" <<EOF

[PostgreSQL]
connections\selected=local
connections\local\host=localhost
connections\local\database=postgres
connections\local\port=5432
connections\local\username=user
connections\local\password=user
connections\local\publicOnly=false
connections\local\geometryColumnsOnly=false
connections\local\save=true
EOF
fi

## add PostGIS 1.4, for those apps that want it
wget http://postgis.refractions.net/download/postgis-1.4.0.tar.gz \
    --output-document="/tmp/postgis-1.4.0.tar.gz"

cd /tmp
tar xzf  postgis-1.4.0.tar.gz
sudo mv postgis-1.4.0 /usr/src/
cd /usr/src/postgis-1.4.0
./configure
make && sudo make install
