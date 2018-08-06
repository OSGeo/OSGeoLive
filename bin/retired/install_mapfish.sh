#!/bin/sh
#############################################################################
#
# Purpose: This script will install mapfish
#
#############################################################################
# Copyright (c) 2010-2018 Open Source Geospatial Foundation (OSGeo)
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

APACHE_CONF="/etc/apache2/conf-enabled/mapfish.conf"
TOMCAT_SERVER_CONF="/etc/tomcat7/server.xml"

MAPFISH_TMP_DIR="/tmp/build_mapfish"
MAPFISH_INSTALL_DIR="/usr/local/lib/mapfish"

 
## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

apt-get --assume-yes install python python-dev \
    cgi-mapserver postgis postgresql-9.3-postgis-2.1 tomcat7 \
    libpq-dev libapache2-mod-fcgid libapache2-mod-wsgi \
    patch python-setuptools
    #TODO: firebug no longer in repos

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

echo "Create $MAPFISH_TMP_DIR directory"
mkdir -p "$MAPFISH_TMP_DIR"

echo "Create $MAPFISH_INSTALL_DIR directory"
mkdir -p "$MAPFISH_INSTALL_DIR"

cd "$MAPFISH_INSTALL_DIR"
rm -fr MapfishSample
svn export --quiet http://mapfish.org/svn/mapfish/sample/trunk MapfishSample
cd MapfishSample

# patch for PostGIS 2.0 #################
rm ./geodata/create_database.bash.in
cp "$BUILD_DIR"/../app-conf/mapfish/create_database.bash.in ./geodata/
rm ./mapserver/mapfishsample.map.in
cp "$BUILD_DIR"/../app-conf/mapfish/mapfishsample.map.in ./mapserver/
#########################################

# generate buildout_osgeolive.cfg
cat << EOF > buildout_osgeolive.cfg
[buildout]
extends = buildout.cfg
parts += print deploy-print
index = http://pypi.camptocamp.net/pypi/

[deploy-print]
output = /var/lib/tomcat7/webapps/print-mapfishsample-\${vars:instanceid}.war

[vars]
apache-entry-point = /mapfishsample_2.2/
instanceid = osgeolive
mapserv_host = localhost
print_host = localhost
pg_version = 9.3
mapserver_jpeg_driver = AGG/JPEG
EOF

if [ ! -f ./buildout/bin/buildout ] ; then
    python bootstrap.py --distribute --version 1.5.2
fi

./buildout/bin/buildout -c buildout_osgeolive.cfg

# set default user/password to www-data
sudo -u postgres createuser --superuser www-data
echo "alter role \"www-data\" with password 'www-data'" \
   > "$MAPFISH_TMP_DIR/mapfish_www-data.sql"
sudo -u postgres psql --quiet -f "$MAPFISH_TMP_DIR/mapfish_www-data.sql"

# drop, then create and populate database
sudo -u postgres ./geodata/create_database.bash -p -d

# add proj 900913 if not exists
grep "<900913>" /usr/share/proj/epsg
if [ $? -ne 0 ] ; then
    echo "" >> /usr/share/proj/epsg
    echo "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs" >> /usr/share/proj/epsg
fi

# update tomcat server.xml conf to enable ajp
wget -O - "http://www.mapfish.org/downloads/foss4g_livedvd/tomcat-server.xml.patch" \
    | patch -N "$TOMCAT_SERVER_CONF"

#/etc/init.d/tomcat7 restart

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

# install startup/shutdown scripts for tomcat

if [ ! -e "$MAPFISH_INSTALL_DIR/mapfish-start.sh" ] ; then
   cat << EOF > "$MAPFISH_INSTALL_DIR/mapfish-start.sh"
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" = "" ]; then
    sudo service tomcat7 start
    (sleep 2; echo "25"; sleep 2; echo "50"; sleep 2; echo "75"; sleep 2; echo "100") | zenity --progress --auto-close --text "MapFish starting"
fi
sensible-browser http://localhost/mapfishsample/osgeolive/wsgi/
EOF
fi

if [ ! -e "$MAPFISH_INSTALL_DIR/mapfish-stop.sh" ] ; then
   cat << EOF > "$MAPFISH_INSTALL_DIR/mapfish-stop.sh"
#!/bin/bash
STAT=\`sudo service tomcat7 status | grep pid\`
if [ "\$STAT" != "" ]; then
    sudo service tomcat7 stop
    zenity --info --text "MapFish stopped"
fi
EOF
fi

chmod 755 "$MAPFISH_INSTALL_DIR/mapfish-start.sh"
chmod 755 "$MAPFISH_INSTALL_DIR/mapfish-stop.sh"

# install menu and desktop shortcuts
wget -nv -P "$MAPFISH_INSTALL_DIR" \
   "http://www.mapfish.org/downloads/foss4g_livedvd/mapfish.png"

mkdir -p /usr/local/share/applications
cat << EOF > /usr/local/share/applications/MapFish-start.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=MapFish Start
Comment=View MapFish sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=$MAPFISH_INSTALL_DIR/mapfish-start.sh
Icon=/usr/local/lib/mapfish/mapfish.png
Terminal=false
StartupNotify=false
EOF
cp /usr/local/share/applications/MapFish-start.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/MapFish-start.desktop"

cat << EOF > /usr/local/share/applications/MapFish-stop.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=MapFish Stop
Comment=View MapFish sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=$MAPFISH_INSTALL_DIR/mapfish-stop.sh
Icon=/usr/local/lib/mapfish/mapfish.png
Terminal=false
StartupNotify=false
EOF
cp /usr/local/share/applications/MapFish-stop.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/MapFish-stop.desktop"

#cleanup
#  nah, we'll want them for other things later (e.g. libgdal-dev)
#apt-get --assume-yes remove libpq-dev python-dev


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
