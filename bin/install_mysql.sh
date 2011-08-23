#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This software is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install mysql (put it up front because it has an interactive prompt)

#attempt at setting the root password without the need for interaction
PASSWORD="user"

# pre-seed answers to installer questions:
cat << EOF | debconf-set-selections
mysql-server-5.1  mysql-server/root_password  password $PASSWORD
mysql-server-5.1  mysql-server/root_password  seen true
mysql-server-5.1  mysql-server/root_password_again  password $PASSWORD
mysql-server-5.1  mysql-server/root_password_again  seen true
EOF

apt-get install --yes mysql-server mysql-admin



## well maybe that didn't work, let's see...
MYSQL_ADMIN_NM=`grep -w '^user' /etc/mysql/debian.cnf | head -n 1 | cut -f2 -d'=' | awk '{print $1}'`
MYSQL_ADMIN_PW=`grep -w '^password' /etc/mysql/debian.cnf | head -n 1 | cut -f2 -d'=' | awk '{print $1}'`

echo ".. MySQL admin name is <$MYSQL_ADMIN_NM>. (see /etc/mysql/debian.cnf)"

echo "
CREATE USER 'user'@'localhost' IDENTIFIED BY 'user';
GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;
" | mysql -u"$MYSQL_ADMIN_NM" -p"$MYSQL_ADMIN_PW"
