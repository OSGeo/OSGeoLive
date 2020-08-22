#!/bin/sh
# Copyright (c) 2009-2020 The Open Source Geospatial Foundation and others.
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
# This script will install postgres and postgis
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
PG_VERSION="12"

apt-get install --yes postgis postgis-gui "postgresql-$PG_VERSION-postgis-3" "postgresql-$PG_VERSION-postgis-3-scripts" "postgresql-$PG_VERSION-ogr-fdw"

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

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
