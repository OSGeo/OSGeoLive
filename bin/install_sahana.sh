#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This program is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install Sahana

# Requires: Apache2, PHP5, MySQL

#see also
# http://eden.sahanafoundation.org/wiki/InstallationGuidelinesLinux


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_sahana"
mkdir -p "$TMP_DIR"

# Install dependencies.
apt-get --assume-yes install apache2 mysql-server libapache2-mod-php5 \
  php5-gd php5-mysql

if [ ! -x "`which wget`" ] ; then
    echo "ERROR: wget is required, please install it and try again"
    exit 1
fi


cd "$TMP_DIR"

wget -c  --progress=dot:mega \
   "http://launchpad.net/sahana-agasti/0.6/0.6.4/+download/sahana-0.6.4.tgz"

tar xzf sahana-0.6.4.tgz

mkdir /usr/local/share/sahana
\cp -r sahana-phase2/* /usr/local/share/sahana/

ln -s  /usr/local/share/sahana/www /var/www/sahana

invoke-rc.d apache2 restart
#invoke-rc.d mysql restart
service mysql restart

# check mysql extention is installed with: "php -m | grep mysql"

# connect:  http://localhost/sahana/index.php

# create config.inc file, copy to /usr/local/share/sahana/conf/

# ==Ensure Folders writable by webserver==
#  These folders need to be writable by the webserver for the administration
#   of the GIS OpenLayers plugin:
#chown apache www/res/OpenLayers/defs
# chown apache www/res/OpenLayers/files
# chown apache www/res/img/markers

## FIXME
#chmod a+w /usr/local/share/sahana/www/tmp
#chmod a+w /usr/local/share/sahana/conf
chown www-data /usr/local/share/sahana/www/tmp
chown www-data /usr/local/share/sahana/conf

# admin name: admin  user name: sahana
# admin/user PW: agasti4osgeo


# once started add two new (fictional) locations: Lilliput and Blefuscu
#  25S latitude, 85E longitude
# http://en.wikipedia.org/wiki/Lilliput_and_Blefuscu

# ...


#Add Launch icon to desktop
if [ ! -e /usr/share/applications/sahana.desktop ] ; then
   cat << EOF > /usr/share/applications/sahana.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Sahana
Comment=Sahana Agasti
Categories=Application;Internet;Relief;
Exec=firefox http://localhost/sahana/
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/sahana.desktop "$USER_HOME/Desktop/"

