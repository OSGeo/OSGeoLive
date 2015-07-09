#!/bin/sh
# Copyright (c) 2015 Open Source Geospatial Foundation (OSGeo)
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
# This script installs Apache SOLR.

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP="/tmp/build_solr"
WARDIR="/var/lib/tomcat7/webapps"
TOMCAT_CONFDIR="/var/lib/tomcat7/conf"
TOMCAT_LIB="/usr/share/tomcat7/lib"
SOLR_HOME="/var/lib/tomcat7/solr"

mkdir -p "$TMP"

#Install Tomcat
apt-get -q update
apt-get --assume-yes install tomcat7 tomcat7-admin

service tomcat7 stop

cd "$TMP"
echo 'Installing commons-logging'
wget http://archive.apache.org/dist/commons/logging/binaries/commons-logging-1.1.3-bin.tar.gz
tar -zxvf commons-logging-1.1.3-bin.tar.gz
cp commons-logging-1.1.3/commons-logging-*.jar "$TOMCAT_LIB/"
rm -rf commons-logging*

echo 'Installing slf4j'
wget http://www.slf4j.org/dist/slf4j-1.7.5.tar.gz
tar -zxvf slf4j-1.7.5.tar.gz
cp slf4j-1.7.5/slf4j-*.jar "$TOMCAT_LIB/"
rm -rf slf4j*

echo 'Installing SOLR war'
wget http://archive.apache.org/dist/lucene/solr/4.2.1/solr-4.2.1.tgz
tar -zxvf solr-4.2.1.tgz
cp solr-4.2.1/dist/solr-4.2.1.war "$WARDIR/solr.war"

echo 'Installing SOLR home'
mkdir -p "$SOLR_HOME"
cp -R solr-4.2.1/example/solr/* "$SOLR_HOME/"
chown -R tomcat7:tomcat7 "$SOLR_HOME"

service tomcat7 start
sleep 60
service tomcat7 stop

rm "$WARDIR/solr/WEB-INF/web.xml"
cp "$BUILD_DIR/../app-conf/solr/web.xml" "$WARDIR/solr/WEB-INF/web.xml"

####
./diskspace_probe.sh "`basename $0`" end
