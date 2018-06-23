#!/bin/sh
#############################################################################
#
# Purpose: This script will install tomcat 8
#
#############################################################################
# Copyright (c) 2009-2018 Open Source Geospatial Foundation (OSGeo) and others.
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
# - introduce global variable TOMCAT_VERSION to have only one point to update
#   on tomcat updates
# - add start/stop to sudoers file to allow alternate VM users to launch 
#   without password?
#
# To manually launch:
# ===================
# sudo /etc/init.d tomcat8 start
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi


apt-get install --yes tomcat8 tomcat8-admin

#Add the following lines to <tomcat-users> in /etc/tomcat7/tomcat-users.xml
#<role rolename="manager"/>
#<user username="user" password="user" roles="manager"/>


cp ../app-conf/tomcat/tomcat-users.xml \
   /etc/tomcat8/tomcat-users.xml

chown tomcat8:tomcat8 /etc/tomcat8/tomcat-users.xml

# something screwed up with the ISO permissions:
chgrp tomcat8 /usr/share/tomcat8/bin/*.sh
adduser "$USER_NAME" tomcat8

service tomcat8 stop

# Assign 1GB of RAM to default tomcat
sed -i -e 's|-Djava.awt.headless=true -XX:+UseConcMarkSweepGC|-Djava.awt.headless=true -Xmx1024m -XX:+UseConcMarkSweepGC|' /etc/default/tomcat8

####
./diskspace_probe.sh "`basename $0`" end
