#!/bin/sh
# Copyright (c) 2009-2016 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
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
# This script will install postgres, postgis, and pgadmin3
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# Not to be confused with PGIS_Version, this has one less number and period
#  to correspond to install paths
PG_VERSION="9.4"

#debug:
echo "#DEBUG The locale settings are currently:"
locale

# DB is created in the current locale, which was reset to "C". Put it
#  back to UTF so the templates will be created using UTF8 encoding.
unset LC_ALL
update-locale LC_ALL=en_US.UTF-8

# another debug
echo "#DEBUG The locale settings updated:"
locale
echo "------------------------------------"

##-- TODO pgdg repo ?
apt-get install --yes postgis "postgresql-$PG_VERSION-postgis-2.2"
#TODO: Restore postgis-gui in the future.

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

apt-get install --yes pgadmin3

### config ###

#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER_NAME

echo "alter role \"user\" with password 'user'" > /tmp/build_postgre.sql
sudo -u postgres psql -f /tmp/build_postgre.sql
# rm /tmp/build_postgre.sql

#add a gratuitous db called user to avoid psql inconveniences
sudo -u $USER_NAME createdb -E UTF8 $USER_NAME
sudo -u "$USER_NAME" psql -d "$USER_NAME" -c 'VACUUM ANALYZE;'

#include pgadmin3 profile for connection
for FILE in  pgadmin3  pgpass  ; do
    cp ../app-conf/postgis/"$FILE" "$USER_HOME/.$FILE"

    chown $USER_NAME:$USER_NAME "$USER_HOME/.$FILE"
    chmod 600 "$USER_HOME/.$FILE"
done

#enable gdal drivers
cat << EOF >> "/var/lib/postgresql/$PG_VERSION/main/postgresql.auto.conf"

## https://trac.osgeo.org/gdal/wiki/SecurityIssues
postgis.gdal_enabled_drivers = 'ENABLE_ALL'
postgis.enable_outdb_rasters = TRUE

EOF

## TODO review - needed for 1404 ?!
# fix for 2.1.1-1~precise3 package breakage
# rm -f /usr/share/java/postgis.jar
# ln -s /usr/share/java/postgis-jdbc-2.1.0~rc1.jar /usr/share/java/postgis.jar

#shp2pgsql-gui desktop launcher
cat << EOF > /usr/share/applications/shp2pgsql-gui.desktop
[Desktop Entry]
Type=Application
Name=shp2pgsql
Comment=Shapefile to PostGIS Import Tool
Categories=Application;Geography;Geoscience;
Exec=shp2pgsql-gui
Icon=pgadmin3
Terminal=false
EOF

cp -a /usr/share/applications/shp2pgsql-gui.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/shp2pgsql-gui.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
