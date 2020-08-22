#!/bin/sh
#############################################################################
#
# Purpose: This script will install tomcat 9
#
#############################################################################
# Copyright (c) 2009-2020 Open Source Geospatial Foundation (OSGeo) and others.
#
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
#
# TODO:
# =====
# - add start/stop to sudoers file to allow alternate VM users to launch 
#   without password?
#
# To manually launch:
# ===================
# sudo service tomcat9 start
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi


apt-get install --yes tomcat9 tomcat9-admin

#Add the following lines to <tomcat-users> in /etc/tomcat7/tomcat-users.xml
#<role rolename="manager"/>
#<user username="user" password="user" roles="manager"/>


cp ../app-conf/tomcat/tomcat-users.xml \
   /etc/tomcat9/tomcat-users.xml

chown tomcat:tomcat /etc/tomcat9/tomcat-users.xml

# something screwed up with the ISO permissions:
chgrp tomcat /usr/share/tomcat9/bin/*.sh
adduser "$USER_NAME" tomcat

service tomcat9 stop

# Assign 1GB of RAM to default tomcat
sed -i -e 's|-Djava.awt.headless=true|-Djava.awt.headless=true -Xmx1024m|' /etc/default/tomcat9

####
./diskspace_probe.sh "`basename $0`" end
