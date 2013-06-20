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
# This script will install apache2

# Running:
# =======
# sudo /etc/init.d/apache2 start
SCRIPT="install_apache2.sh"
echo "==============================================================="
echo "$SCRIPT"
echo "==============================================================="

apt-get install --yes apache2

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

# add "user" to the www-data group
adduser "$USER_NAME" www-data


mkdir -p /var/www
wget -nv http://www.osgeo.org/favicon.ico -O /var/www/favicon.ico

echo "==============================================================="
echo "Finished $SCRIPT"
echo Disk Usage1:, $SCRIPT, `df . -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, $SCRIPT, `df . -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
echo "==============================================================="