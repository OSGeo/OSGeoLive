#!/bin/sh
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
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

# About:
# =====
# This script install mapfish

# Running:
# =======
# sudo ./install_mapfish.sh

BIN="/usr/bin"
USER_NAME="user"
USER_DIR="/home/user"

APACHE_CONF="/etc/apache2/conf.d/mapfish"
TOMCAT_SERVER_CONF="/etc/tomcat6/server.xml"

INSTALL_DIR="/usr/lib"
MAPFISH_INSTALL_DIR="$INSTALL_DIR/mapfish"

OLDPWD=`pwd`

 
## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

apt-get --assume-yes install python2.6 python2.6-dev \
    cgi-mapserver postgis postgresql-8.4-postgis tomcat6 \
    libpq-dev libapache2-mod-fcgid libapache2-mod-wsgi \
    firebug

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

echo "Create $MAPFISH_INSTALL_DIR directory"
mkdir -p $MAPFISH_INSTALL_DIR

cd $MAPFISH_INSTALL_DIR
rm -fr MapfishSample
svn co http://mapfish.org/svn/mapfish/sample/trunk MapfishSample
cd MapfishSample

# generate buildout_osgeolive.cfg
cat << EOF > buildout_osgeolive.cfg
[buildout]
extends = buildout.cfg
parts += print deploy-print
index = http://pypi.camptocamp.net/pypi/

[deploy-print]
output = /var/lib/tomcat6/webapps/print-mapfishsample-\${vars:instanceid}.war

[vars]
apache-entry-point = /mapfishsample_2.0/
instanceid = osgeolive
mapserv_host = localhost
print_host = localhost
pg_version = 8.4
EOF

if [ ! -f ./buildout/bin/buildout ] ; then
    python bootstrap.py --distribute --version 1.5.2
fi

./buildout/bin/buildout -c buildout_osgeolive.cfg

# set default user/password to www-data
sudo -u postgres createuser --superuser www-data
echo "alter role \"www-data\" with password 'www-data'" > /tmp/mapfish_www-data.sql
sudo -u postgres psql -f /tmp/mapfish_www-data.sql

sudo -u postgres dropdb v2.0_mapfishsample
sudo -u postgres ./geodata/create_database.bash -p

# add proj 900913 if not exists
grep "<900913>" /usr/share/proj/epsg
if [ $? -ne 0 ] ; then
    echo "" >> /usr/share/proj/epsg
    echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs" >> /usr/share/proj/epsg
fi

# update tomcat server.xml conf to enable ajp
wget -O $TOMCAT_SERVER_CONF http://www.mapfish.org/downloads/foss4g_livedvd/server.xml
/etc/init.d/tomcat6 restart

# configure apache
a2enmod proxy_ajp
a2enmod fcgid
a2enmod wsgi
a2enmod headers
a2enmod expires
a2enmod rewrite
cat << EOF > $APACHE_CONF
Include $MAPFISH_INSTALL_DIR/MapfishSample/apache/*.conf
EOF
apache2ctl restart

# install menu and desktop shortcuts
wget -P $MAPFISH_INSTALL_DIR -c http://www.mapfish.org/downloads/foss4g_livedvd/mapfish.png
cat << EOF > /usr/share/applications/MapFish.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=MapFish
Comment=View MapFish sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=sensible-browser http://localhost/mapfishsample/osgeolive/wsgi/
Icon=/usr/lib/mapfish/mapfish.png
Terminal=false
StartupNotify=false
EOF
cp /usr/share/applications/MapFish.desktop $USER_DIR/Desktop/
chown $USER_NAME:$USER_NAME $USER_DIR/Desktop/MapFish.desktop

#cleanup
apt-get --assume-yes remove libpq-dev
cd $OLDPWD
