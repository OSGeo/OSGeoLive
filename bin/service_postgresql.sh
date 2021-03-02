#!/bin/sh
#############################################################################
#
# Purpose: This script will install postgreSQL pgadmin3
#
#############################################################################
# Copyright (c) 2009-2021 The Open Source Geospatial Foundation and others.
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

PG_VERSION="12"

#debug:
echo "#DEBUG The locale settings are currently:"
locale

# DB is created in the current locale, which was reset to "C". Put it
#  back to UTF so the templates will be created using UTF8 encoding.
unset LC_ALL
update-locale LC_ALL=en_US.UTF-8
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

# another debug
echo "#DEBUG The locale settings updated:"
locale
echo "------------------------------------"

apt-get install --yes postgresql-"$PG_VERSION" pgadmin4

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

### config ###
service postgresql start
#set default user/password to the system user for easy login
sudo -u postgres createuser --superuser $USER_NAME

echo "alter role \"user\" with password 'user'" > /tmp/build_postgres.sql
sudo -u postgres psql -f /tmp/build_postgres.sql
# rm /tmp/build_postgre.sql

#add a gratuitous db called user to avoid psql inconveniences
sudo -u $USER_NAME createdb -E UTF8 $USER_NAME
sudo -u "$USER_NAME" psql -d "$USER_NAME" -c 'VACUUM ANALYZE;'

#include pgadmin3 profile for connection
for FILE in  pgadmin3  pgpass  ; do
    cp ../app-conf/postgresql/"$FILE" "$USER_HOME/.$FILE"

    chown $USER_NAME:$USER_NAME "$USER_HOME/.$FILE"
    chmod 600 "$USER_HOME/.$FILE"
done

mkdir -p "$USER_HOME/.pgadmin"
cp ../app-conf/postgresql/pgadmin4.db "$USER_HOME/.pgadmin/pgadmin4.db"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
