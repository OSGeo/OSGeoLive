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


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


add-apt-repository --yes ppa:developmentseed/mapbox

apt-get -q update

apt-get --assume-yes install tilemill

cp /usr/share/applications/tilemill.desktop "$USER_HOME/Desktop/"


#################
# with that out of the way we download the OSM Bright demo
#  instructs from
#  http://mapbox.com/tilemill/docs/guides/osm-bright-ubuntu-quickstart/

# wget -N --progress:dot=mega \
#    https://github.com/mapbox/osm-bright/zipball/master


# edit /etc/postgresql/8.4/main/pg_hba.conf
#  "Page down to the bottom section of the file and adjust all local
#  access permissions to "trust". This will allow you to access the
#  PostgreSQL database from the same machine without a password."
#?--not needed as our user already has db admin rights??

# osm postgis db already created and populated by earlier install scripts..

# ... final install continued here:
# http://mapbox.com/tilemill/docs/guides/osm-bright-ubuntu-quickstart/


