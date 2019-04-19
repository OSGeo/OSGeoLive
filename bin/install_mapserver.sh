#!/bin/sh
# Copyright (c) 2009-2019 The Open Source Geospatial Foundation and others.
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
# sudo apt-get remove cgi-mapserver mapserver-bin php-mapscript python-mapscript
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

MAPSERVER_DATA="/usr/local/share/mapserver"

MS_APACHE_CONF_FILE="mapserver.conf"
APACHE_CONF_DIR="/etc/apache2/conf-available/"
APACHE_CONF_ENABLED_DIR="/etc/apache2/conf-enabled/"
MS_APACHE_CONF=$APACHE_CONF_DIR$MS_APACHE_CONF_FILE

TMP_DIR=/tmp/build_mapserver
mkdir "$TMP_DIR"
cd "$TMP_DIR"

# Install MapServer and its php, python bindings.
apt-get install --yes cgi-mapserver mapserver-bin python-mapscript
# PHP 7.x not yet supported on MapServer 7.x
# apt-get install --yes php-mapscript

# Download MapServer data
#wget -c --progress=dot:mega \
#   "http://download.osgeo.org/livedvd/data/mapserver/mapserver-6-2-html-docs.zip"

wget -c --progress=dot:mega \
    "http://download.osgeo.org/livedvd/data/mapserver/mapserver-7-0-html-docs.zip"
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/mapserver/mapserver-itasca-ms70.zip"

# Install docs and demos
if [ ! -d "$MAPSERVER_DATA" ] ; then
    mkdir -p "$MAPSERVER_DATA"/demos

    echo -n "Extracting MapServer html doc in $MAPSERVER_DATA/..."
    unzip -q "$TMP_DIR/mapserver-7-0-html-docs.zip" -d "$MAPSERVER_DATA"/
    echo -n "Done\nExtracting MapServer itasca demo in $MAPSERVER_DATA/demos/..."
    unzip -q "$TMP_DIR/mapserver-itasca-ms70.zip" -d "$MAPSERVER_DATA"/demos/ 
    echo "Done"

    mv "$MAPSERVER_DATA/demos/mapserver-demo-master" "$MAPSERVER_DATA/demos/itasca"
    mv "$MAPSERVER_DATA/mapserver-7-0-docs" "$MAPSERVER_DATA/doc"
    rm -rf "$MAPSERVER_DATA/demos/ms4w"

    echo -n "Patching itasca.map to enable WMS..."
    rm "$MAPSERVER_DATA"/demos/itasca/itasca.map
    wget -c --progress=dot:mega \
        "https://github.com/mapserver/mapserver-demo/raw/master/itasca.map" \
        -O "$MAPSERVER_DATA"/demos/itasca/itasca.map
    echo -n "Done"

    echo "Configuring the system...."
    # Itasca Demo hacks
    mkdir -p /usr/local/www/docs_maps/
    ln -s "$MAPSERVER_DATA"/demos/itasca "$MAPSERVER_DATA"/demos/workshop
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
Name=Mapserver
Comment=Mapserver
Categories=Application;Education;Geography;
Exec=firefox http://localhost/mapserver_demos/itasca/
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
