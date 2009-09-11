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
# This script will install mapserver

# Running:
# =======
# sudo ./mapserver.sh

# Requires: Apache2

HTTPD_CONF="/etc/apache2/httpd.conf"
TMP="/tmp/install_mapserver_tmp"

apt-get install --yes cgi-mapserver

# Adds these 2 lines to /etc/apache2/httpd.conf
# If the lines already exist, then make sure they are uncommented
#   EnableSendfile off
#   ScriptAlias /mapserver /usr/lib/cgi-bin/mapserv

if [ `grep "EnableSendfile off" $HTTPD_CONF | wc -l` -eq 0 ] ; then
  echo "EnableSendfile off" >> $HTTPD_CONF ; 
else
  sed -e 's/^.*EnableSendfile off/EnableSendfile off/' $HTTPD_CONF > $TMP
  mv $TMP $HTTPD_CONF
fi

# Uncomment the following line from httpd.conf, otherwise, add to the end
if [ `grep "ScriptAlias /mapserver /usr/lib/cgi-bin/mapserv" $HTTPD_CONF | wc -l` -eq 0 ] ; then
  echo "ScriptAlias /mapserver /usr/lib/cgi-bin/mapserv" >> $HTTPD_CONF
else
  sed -e 's/^.*ScriptAlias \/mapserver \/usr\/lib\/cgi-bin\/mapserv/ScriptAlias \/mapserver \/usr\/lib\/cgi-bin\/mapserv/' $HTTPD_CONF > $TMP
  mv $TMP $HTTPD_CONF
fi
