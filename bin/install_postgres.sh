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
TMP_DIR="/tmp/build_postgis"

# Install postgis 1.3
apt-get install --yes postgresql-8.3-postgis postgis pgadmin3


###########################
## add PostGIS 1.4, for those apps that want it
#### (which apps are those?)
##  TODO: use repo version when it becomes available  (Ubuntu 9.10 or 10.04 ?)
INSTALL_POSTGIS_1_4=false

if [ "$INSTALL_POSTGIS_1_4" = "true" ] ; then

   apt-get install --yes postgresql-server-dev-8.3 libgeos-dev

   mkdir "$TMP_DIR"
   cd "$TMP_DIR"
   PGIS_VERSION=1.4.0

   if [ ! -e "postgis-$PGIS_VERSION.tar.gz" ] ; then
      wget --progress=dot:mega "http://postgis.refractions.net/download/postgis-$PGIS_VERSION.tar.gz"
   else
      echo "... postgis-$PGIS_VERSION.tar.gz already downloaded"
   fi

   tar xzf "postgis-$PGIS_VERSION.tar.gz"
   cd "postgis-$PGIS_VERSION"
   
   ./configure && make && make install
   if [ $? -ne 0 ] ; then
      echo "ERROR: building PostGIS 1.4"
   else
      # add /usr/local/lib to /etc/ld.so.conf if needed, then run ldconfig
      if [ -d /etc/ld.so.conf.d ] ; then
         echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
      else
         if [ `grep -c '/usr/local/lib' /etc/ld.so.conf` -eq 0 ] ; then
            echo "/usr/local/lib" >> /etc/ld.so.conf
         fi
      fi
      ldconfig
   fi

   #cleanup
   apt-get remove --yes postgresql-server-dev-8.3 libgeos-dev

   cd "$TMP_DIR"
fi
#done
###########################



### config ###

#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER_NAME

echo "alter role \"user\" with password 'user'" > /tmp/build_postgre.sql
sudo -u postgres psql -f /tmp/build_postgre.sql
# rm /tmp/build_postgre.sql

#add a gratuitous db called user to avoid psql inconveniences
sudo -u $USER_NAME createdb $USER_NAME

#configure template postgis database
sudo -u $USER_NAME createdb template_postgis 
sudo -u $USER_NAME createlang plpgsql template_postgis 


pgis_file="/usr/share/postgresql-8.3-postgis/lwpostgis.sql"

if [ "$INSTALL_POSTGIS_1_4" = "true" ] ; then
   if [ -e /usr/share/postgresql/8.3/contrib/postgis.sql ] ; then
      pgis_file="/usr/share/postgresql/8.3/contrib/postgis.sql"
   fi
fi


sudo -u $USER_NAME psql -d template_postgis -f "$pgis_file"
sudo -u $USER_NAME psql -d template_postgis \
   -f /usr/share/postgresql-8.3-postgis/spatial_ref_sys.sql 


#include pgadmin3 profile for connection
for FILE in  pgadmin3  pgpass  ; do
   wget -nv "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/postgis-conf/$FILE" \
      --output-document="/home/$USER_NAME/.$FILE"

    chown $USER_NAME:$USER_NAME "/home/$USER_NAME/.$FILE"
    chmod 600 "/home/$USER_NAME/.$FILE"
done




