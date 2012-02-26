#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install mapserver

# Running:
# =======
# sudo ./install_mapserver.sh

# Requires: Apache2, PHP5
#
# Uninstall:
# ============
# sudo apt-get remove cgi-mapserver mapserver-bin php5-mapscript python-mapscript
# sudo rm /etc/apache2/conf.d/mapserver
# sudo rm -rf /usr/local/share/mapserver/
# sudo rm -rf /usr/local/www/docs_maps

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
DATA_DIR=$USER_HOME/gisvm/app-data/mapserver
MAPSERVER_DATA=/usr/local/share/mapserver

MS_APACHE_CONF="/etc/apache2/conf.d/mapserver"

# Install MapServer and its php, python bindings.
apt-get install --yes cgi-mapserver mapserver-bin php5-mapscript python-mapscript

# Download MapServer data
[ -d $DATA_DIR ] || mkdir $DATA_DIR
[ -f $DATA_DIR/mapserver-6.0-html-docs.zip ] || \
   wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_5/app-data/mapserver/mapserver-6.0-html-docs.zip" \
     -O $DATA_DIR/mapserver-6.0-html-docs.zip
[ -f $DATA_DIR/mapserver-itasca-ms60.zip ] || \
   wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_5/app-data/mapserver/mapserver-itasca-ms60.zip" \
     -O $DATA_DIR/mapserver-itasca-ms60.zip

# Install docs and demos
if [ ! -d $MAPSERVER_DATA ]; then
    mkdir -p $MAPSERVER_DATA/demos
    echo -n "Extracting MapServer html doc in $MAPSERVER_DATA/....."
    unzip -q $DATA_DIR/mapserver-6.0-html-docs.zip -d $MAPSERVER_DATA/
    echo -n "Done\nExtracting MapServer itasca demo in $MAPSERVER_DATA/demos/..."
    unzip -q $DATA_DIR/mapserver-itasca-ms60.zip -d $MAPSERVER_DATA/demos/ 
    echo -n "Done\n"
    mv $MAPSERVER_DATA/demos/workshop $MAPSERVER_DATA/demos/itasca
    mv $MAPSERVER_DATA/mapserver-6.0-docs $MAPSERVER_DATA/doc
    rm -rf $MAPSERVER_DATA/demos/ms4w

    echo -n "Configuring the system...."
    # Itasca Demo hacks
    mkdir -p /usr/local/www/docs_maps/
    ln -s $MAPSERVER_DATA/demos/itasca $MAPSERVER_DATA/demos/workshop
    ln -s /usr/local/share/mapserver/demos /usr/local/www/docs_maps/mapserver_demos
    ln -s /tmp/ /usr/local/www/docs_maps/tmp
fi

# Add MapServer apache configuration
cat << EOF > $MS_APACHE_CONF
EnableSendfile off
DirectoryIndex index.phtml
Alias /mapserver "/usr/local/share/mapserver"
Alias /ms_tmp "/tmp"
Alias /tmp "/tmp"
Alias /mapserver_demos "/usr/local/share/mapserver/demos"

<Directory "/usr/local/share/mapserver">
   AllowOverride None
   Order allow,deny
   Allow from all
</Directory>

<Directory "/usr/local/share/mapserver/demos">
   AllowOverride None
   Order allow,deny
   Allow from all
</Directory>
EOF

echo -n "Done\n"

#Add Launch icon to desktop
#What Icon should be used
INSTALLED_VERSION=`dpkg -s mapserver-bin | grep '^Version:' | awk '{print $2}' | cut -f1 -d~`
if [ ! -e /usr/share/applications/mapserver.desktop ] ; then
   cat << EOF > /usr/share/applications/mapserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapserver
Comment=Mapserver
Categories=Application;Education;Geography;
Exec=firefox http://localhost/mapserver_demos/itasca/
Icon=gnome-globe
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi
cp /usr/share/applications/mapserver.desktop "$USER_HOME/Desktop/"


# share data with the rest of the disc
ln -s /usr/local/share/mapserver/demos/itasca/data \
      /usr/local/share/data/itasca


# Reload Apache
/etc/init.d/apache2 force-reload


