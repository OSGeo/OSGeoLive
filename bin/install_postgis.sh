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
# This script will install postgres 8.4, postgis 1.4 and pgadmin3

# Running:
# =======
# sudo /etc/init.d/postgresql-8.4 start

USER_NAME="user"
TMP_DIR="/tmp/build_postgis"
BIN_DIR=`pwd`
#Not to be confused with PGIS_Version, this has one less number and period to correspond to install paths
PG_VERSION="8.4"

##  Use UbuntuGIS ppa.launchpad repo version, change to main one once it becomes
#    available there (Ubuntu 10.04/Lucid)
# postgis 1.4 is in the UbuntuGIS repository

#Add repositories
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

#Add signed key for repositorys LTS and non-LTS
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  

apt-get update


# how about libpostgis-java ?
apt-get install --yes "postgresql-$PG_VERSION-postgis" postgis pgadmin3 osm2pgsql


if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi



### config ###

#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER_NAME

echo "alter role \"user\" with password 'user'" > /tmp/build_postgre.sql
sudo -u postgres psql -f /tmp/build_postgre.sql
# rm /tmp/build_postgre.sql

#add a gratuitous db called user to avoid psql inconveniences
sudo -u $USER_NAME createdb $USER_NAME

#configure template postgis database
sudo -u $USER_NAME createdb -E UTF8 template_postgis 
sudo -u $USER_NAME createlang plpgsql template_postgis
# Allows non-superusers the ability to create from this template, from GeoDjango manual
sudo -u $USER_NAME psql -1 -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';" 



#pgis_file="/usr/share/postgresql-8.3-postgis/lwpostgis.sql"
## Jul10 TODO resolve location of postgis.sql
pgis_file="/usr/share/postgresql/$PG_VERSION/contrib/postgis-1.5/postgis.sql"

# or is it this one:   ???
#if [ -e /usr/share/postgresql/8.4/contrib/postgis.sql ] ; then
#   pgis_file="/usr/share/postgresql/$PG_VERSION/contrib/postgis.sql"
#fi


sudo -u $USER_NAME psql -d template_postgis -f "$pgis_file"
sudo -u $USER_NAME psql --exit-on-error -d template_postgis \
   -f /usr/share/postgresql/$PG_VERSION/contrib/postgis-1.5/spatial_ref_sys.sql 

# from install_gpsdrive - verify not necessary..
#echo GRANT ALL ON geometry_columns TO $USER_NAME | sudo -u postgres psql -Upostgres gis
#echo GRANT ALL ON spatial_ref_sys  TO $USER_NAME | sudo -u postgres psql -Upostgres gis

#include pgadmin3 profile for connection
for FILE in  pgadmin3  pgpass  ; do
   wget -nv "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-conf/postgis/$FILE" \
      --output-document="/home/$USER_NAME/.$FILE"

    chown $USER_NAME:$USER_NAME "/home/$USER_NAME/.$FILE"
    chmod 600 "/home/$USER_NAME/.$FILE"
done


### load data ###
#cd "$BIN_DIR"
# Jul10 moved load_postgis.sh to main.sh
