#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install ZOO Project
#
# Requires: Apache2, GeoServer (for the demo only)


./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


TMP_DIR=/tmp/build_zoo
if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


apt-get --assume-yes install libmozjs185-1.0 zoo-kernel zoo-services

# Download ZOO Project deb file.
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/zoo/zoo-osgeolive-demo_1.3.0-3_all.deb"

dpkg -i zoo-osgeolive-demo_1.3.0-3_all.deb

a2enmod rewrite
a2enmod cgi

cp /usr/share/applications/zoo-project.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/zoo-project.desktop"

cd /usr/lib/cgi-bin
ldconfig

rm /usr/lib/cgi-bin/main.cfg

cat << EOF > /usr/lib/cgi-bin/main.cfg
[main]
encoding = utf-8
version = 1.0.0
serverAddress = http://localhost/cgi-bin/zoo_loader.cgi
lang = fr-FR,en-CA
tmpPath=/var/www/html/temp/
tmpUrl = ../temp/

[identification]
title = The Zoo WPS Development Server
abstract = Development version of ZooWPS. See http://www.zoo-project.org
fees = None
accessConstraints = none
keywords = WPS,GIS,buffer

[provider]
providerName=ZOO Project
providerSite=http://www.zoo-project.org
individualName=Gerald FENOY
positionName=Developer
role=Dev
addressDeliveryPoint=1280, avenue des Platanes
addressCity=Lattes
addressAdministrativeArea=False
addressPostalCode=34970
addressCountry=fr
addressElectronicMailAddress=gerald@geolabs.fr
phoneVoice=False
phoneFacsimile=False
EOF

# Reload Apache
/etc/init.d/apache2 force-reload

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
