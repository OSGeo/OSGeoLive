#!/bin/sh
#############################################################################
#
# Purpose: This script will install apache2
#
#############################################################################
# Copyright (c) 2009-2022 Open Source Geospatial Foundation (OSGeo) and others.
#
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

apt-get install --yes apache2

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

# add "user" to the www-data group
adduser "$USER_NAME" www-data


mkdir -p /var/www/html
mkdir -p /var/log/apache2
touch /var/log/apache2/error.log
cp "$BUILD_DIR"/../app-conf/apache2/favicon.ico \
  /var/www/html/favicon.ico

rm /var/www/html/index.html

cat << EOF > /var/www/html/index.html
<html>
<head>
<meta http-equiv="Refresh" content="0;url=http://localhost/osgeolive" />
</head>
<body>
</body>
</html>
EOF


####
./diskspace_probe.sh "`basename $0`" end
