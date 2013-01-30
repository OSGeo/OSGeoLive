#!/bin/sh
# Copyright (c) 2012 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install TileMill
#    this script authored by H.Bowman <hamish_b  yahoo com> (if you can call it that)
#    homepage: http://mapbox.com/tilemill

# Need to get 68.4 MB of archives.
# After this operation, 186 MB of additional disk space will be used.

echo "==============================================================="
echo "install_tilemill.sh"
echo "==============================================================="

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


add-apt-repository --yes ppa:developmentseed/mapbox

apt-get -q update

apt-get --assume-yes install tilemill

cp /usr/share/applications/tilemill.desktop "$USER_HOME/Desktop/"

mkdir -p "$USER_HOME"/Documents/MapBox/

cat << EOF > "$USER_HOME"/Documents/MapBox/app.db
{"key":"/api/Favorite/host%3Dlocalhost%20port%3D5432%20user%3Duser%20password%3Duser%20dbname%3Dosm_local","val":{"id":"host=localhost port=5432 user=user password=user dbname=osm_local"}}
{"key":"/api/Favorite/host%3Dlocalhost%20port%3D5432%20user%3Duser%20password%3Duser%20dbname%3Dosm_local_smerc","val":{"id":"host=localhost port=5432 user=user password=user dbname=osm_local_smerc"}}
{"key":"/api/Favorite/host%3Dlocalhost%20port%3D5432%20user%3Duser%20password%3Duser%20dbname%3Dnatural_earth2","val":{"id":"host=localhost port=5432 user=user password=user dbname=natural_earth2"}}
EOF
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/Documents

mkdir -p /etc/skel/Documents/MapBox/
cp "$USER_HOME"/Documents/MapBox/app.db /etc/skel/Documents/MapBox/


exit 0



# todo:

#################
# with that out of the way we download the OSM Bright demo
#  instructs from
#  http://mapbox.com/tilemill/docs/guides/osm-bright-ubuntu-quickstart/

TMP_DIR=/tmp/build_tilemill
mkdir "$TMP_DIR"
cd "$TMP_DIR"

wget -N --progress:dot=mega -O mapbox-osm-bright.zip \
    https://github.com/mapbox/osm-bright/zipball/master

unzip -q mapbox-osm-bright.zip
cd mapbox-osm-bright-*

# to use the smerc or ll/wgs84 db?
sed -e 's/\["dbname"\]   = "osm"/[dbname]="osm_local_smerc"/' \
   configure.py.sample > configure.py

#fixme: update bbox to host city in sperc coords
#    -e 's/\["extent"\] = .*/\[extent\] = "1,2,3,4"/'

# can we re-use the nat earth2 shapefiles here as is done for gpsdrive's mapnik's osm.xml?
# wget http://tile.osm.org/processed_p.tar.bz2a   #  380mb
# wget http://tile.osm.org/shoreline_300.tar.bz2  #   40mb

./configure.py
cd build/

# ... tbc


# edit /etc/postgresql/9.1/main/pg_hba.conf
#  "Page down to the bottom section of the file and adjust all local
#  access permissions to "trust". This will allow you to access the
#  PostgreSQL database from the same machine without a password."
#?--not needed as our user already has db admin rights??

# osm postgis db already created and populated by earlier install scripts..

# ... final install continued here:
# http://mapbox.com/tilemill/docs/guides/osm-bright-ubuntu-quickstart/


