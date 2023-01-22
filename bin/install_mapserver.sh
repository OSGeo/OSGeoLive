#!/bin/sh
# Copyright (c) 2009-2022 The Open Source Geospatial Foundation and others.
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
# This script will install mapserver
#
# Requires: Apache2, PHP5
#
# Uninstall:
# ============
# sudo apt-get remove cgi-mapserver mapserver-bin python3-mapscript php-mapscript-ng
# sudo rm /etc/apache2/conf-available/mapserver
# sudo rm -rf /usr/local/share/mapserver/
# sudo rm -rf /usr/local/www/docs_maps

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# copy MapServer CONFIG file to its default location in /etc
cp -f "$BUILD_DIR/../app-conf/mapserver/mapserver.conf" "/etc/mapserver.conf"

MAPSERVER_DATA="/usr/local/share/mapserver"

MS_APACHE_CONF_FILE="mapserver.conf"
APACHE_CONF_DIR="/etc/apache2/conf-available/"
APACHE_CONF_ENABLED_DIR="/etc/apache2/conf-enabled/"
MS_APACHE_CONF=$APACHE_CONF_DIR$MS_APACHE_CONF_FILE

TMP_DIR=/tmp/build_mapserver
mkdir "$TMP_DIR"
cd "$TMP_DIR"

# Install MapServer and its php, python bindings.
apt-get install --yes cgi-mapserver mapserver-bin python3-mapscript php-mapscript-ng

# Download MapServer data

MS_DEMO_VERSION="1.2"
MS_DOCS_VERSION="8-0"

wget -c --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/mapserver/mapserver-$MS_DOCS_VERSION-html-docs.zip"
wget -c --progress=dot:mega \
   "https://github.com/mapserver/mapserver-demo/archive/v$MS_DEMO_VERSION.zip"

# Install docs and demos
if [ ! -d "$MAPSERVER_DATA" ] ; then
    mkdir -p "$MAPSERVER_DATA"/demos

    echo -n "Extracting MapServer html doc in $MAPSERVER_DATA/..."
    unzip -qo "$TMP_DIR/mapserver-$MS_DOCS_VERSION-html-docs.zip"
    mv "$TMP_DIR/mapserver-$MS_DOCS_VERSION-docs" "$MAPSERVER_DATA/doc"
    rm -f "$TMP_DIR/mapserver-$MS_DOCS_VERSION-html-docs.zip"
    echo "Done"

    echo -n "Extracting MapServer Itasca demo in $MAPSERVER_DATA/demos/..."
    unzip -qo "$TMP_DIR/v$MS_DEMO_VERSION.zip"
    mv "$TMP_DIR/MapServer-demo-$MS_DEMO_VERSION" "$MAPSERVER_DATA"/demos/itasca
    rm -f "$TMP_DIR/v$MS_DEMO_VERSION.zip"
    echo "Done"

    echo "Configuring the system...."
    # Itasca Demo hacks
    mkdir -p /usr/local/www/docs_maps/
    ln -s "$MAPSERVER_DATA"/demos/itasca "$MAPSERVER_DATA"/demos/workshop # for demo application
    ln -s /usr/local/share/mapserver/demos /usr/local/www/docs_maps/mapserver_demos
    ln -s /tmp /usr/local/www/docs_maps/tmp
    ln -s /tmp /var/www/html/tmp
fi


# Add MapServer apache configuration
cat << EOF > "$MS_APACHE_CONF"
EnableSendfile off
DirectoryIndex index.phtml
Alias /mapserver "/usr/local/share/mapserver"
Alias /ms_tmp "/tmp"
Alias /tmp "/tmp"
Alias /mapserver_demos "/usr/local/share/mapserver/demos"

<Directory "/usr/local/share/mapserver">
  Require all granted
  Options +Indexes
</Directory>

<Directory "/usr/local/share/mapserver/demos">
  Require all granted
  Options +Indexes
</Directory>

<Directory "/tmp">
  Require all granted
  Options +Indexes
</Directory>
EOF

# Make sure Apache has cgi-bin setup
a2enmod cgi
a2enconf $MS_APACHE_CONF_FILE
echo "Finished configuring Apache"

#Add Launch icon to desktop
echo 'Downloading MapServer logo ...'
mkdir -p /usr/local/share/icons
wget -c --progress=dot:mega \
   -O /usr/local/share/icons/mapserver.png \
   "https://github.com/OSGeo/OSGeoLive-doc/raw/master/doc/images/projects/mapserver/logo_mapserver.png"

INSTALLED_VERSION=`dpkg -s mapserver-bin | grep '^Version:' | awk '{print $2}' | cut -f1 -d~`

cat << EOF > "/usr/share/applications/mapserver.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=MapServer
Comment=MapServer
Categories=Application;Education;Geography;
Exec=firefox http://localhost/mapserver_demos/itasca/ http://localhost/mapserver/doc/ http://localhost/osgeolive/en/quickstart/mapserver_quickstart.html
Icon=mapserver
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF


cp /usr/share/applications/mapserver.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/mapserver.desktop"


# share data with the rest of the disc
ln -s /usr/local/share/mapserver/demos/itasca/data \
      /usr/local/share/data/itasca


# Reload Apache
#/etc/init.d/apache2 force-reload
service apache2 --full-restart

# cleanup
cd "$MAPSERVER_DATA"/doc/_static/
rm -rf `find | grep '/\.svn'`


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
