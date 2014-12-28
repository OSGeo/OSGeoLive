#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install tomcat 6

# To manually launch:
# ===================
# sudo /etc/init.d tomcat6 start

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi


apt-get install --yes tomcat6 tomcat6-admin

#Add the following lines to <tomcat-users> in /etc/tomcat6/tomcat-users.xml
#<role rolename="manager"/>
#<user username="user" password="user" roles="manager"/>


cp ../app-conf/tomcat/tomcat-users.xml \
   /etc/tomcat6/tomcat-users.xml

chown tomcat6:tomcat6 /etc/tomcat6/tomcat-users.xml


# something screwed up with the ISO permissions:
chgrp tomcat6 /usr/share/tomcat6/bin/*.sh
adduser "$USER_NAME" tomcat6

# TODO: (?)
# add start/stop to sudoers file to allow alternate VM users to launch without password?

service tomcat6 stop

####
./diskspace_probe.sh "`basename $0`" end
