#!/bin/sh
# Copyright 2009, Open Source Geospatial Foundation. All rights reserved.
#
# This program is dual licensed under the GNU General Public License: 
# http://svn.mapbender.org/trunk/mapbender/gpl.txt
# and Simplified BSD license:
# http://svn.osgeo.org/mapbender/trunk/mapbender/license/simplified_bsd.txt
#
# This file is part of Mapbender.
#
#######################  GNU General Public License  ########################
# Mapbender is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Mapbender is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mapbender.  If not, see <http://www.gnu.org/licenses/>.
#
#######################    Simplified BSD License    ########################
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright 
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright 
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the 
#      distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# http://opensource.org/licenses/bsd-license.php

# About:
# =====
# This script will install mapbender

# Running:
# =======
# sudo ./install_mapbender.sh

# Requires: Apache2, PHP5, postgresql/postgis
#
# Uninstall:
# ============
# sudo rm -rf /var/www/mapbender

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_mapbender"
INSTALLURL="http://www.mapbender.org/download/"
INSTALLFILE="mapbender_osgeolive"
INSTALL_DIR="/var/www"
MAPBENDER_DATABASE_NAME="mapbender" 
MAPBENDER_DATABASE_TEMPLATE="template_postgis"
MAPBENDER_DATABASE_USER="user"

mkdir -p "$TMP_DIR"

# Install mapbender dependencies.
echo "Installing mapbender"

apt-get install --assume-yes php5 php5-imagick php5-pgsql 

if [ ! -x "`which wget`" ] ; then
    apt-get --assume-yes install wget
fi

if [ ! -x "`which gettext`" ] ; then
    apt-get --assume-yes install gettext
fi

if [ ! -x "`which unzip`" ] ; then
    apt-get --assume-yes install unzip
fi

if [ ! -x "`which etherape`" ] ; then
    apt-get --assume-yes install etherape
fi

if [ ! -x "`which pgadmin3`" ] ; then
    apt-get --assume-yes install pgadmin3
fi

# check more libraries...


# download and unzip sources...

cd "$TMP_DIR"
if [ ! -e mapbender_osgeo.zip ] ; then 
   wget -O mapbender_osgeo.zip --progress=dot:mega \
      "$INSTALLURL""$INSTALLFILE".zip
else
    echo "... Mapbender already downloaded"
fi

# uncompress mapbender
unzip -q -o mapbender_osgeo.zip 
rm -rf "$INSTALL_DIR/mapbender"
cp -R "$INSTALLFILE" "$INSTALL_DIR/mapbender"
chmod -R uga+r "$INSTALL_DIR/mapbender"
chown -R www-data:www-data "$INSTALL_DIR/mapbender"
chown -R user "$INSTALL_DIR/mapbender/resources"
chown -R user "$INSTALL_DIR/mapbender/tools"



# create mabpender database 

cd $INSTALL_DIR/mapbender/resources/db
chmod +x install_2.6.sh 
sudo -u $USER_NAME ./install_2.6.sh localhost 5432 $MAPBENDER_DATABASE_NAME $MAPBENDER_DATABASE_TEMPLATE $MAPBENDER_DATABASE_USER
chown -R www-data:www-data "$INSTALL_DIR/mapbender/resources"
chown -R www-data:www-data "$INSTALL_DIR/mapbender/tools"

#Create apache2 configuration for mapbender
echo "#Configure apache for mapbender " > /etc/apache2/conf.d/mapbender
echo "Alias /mapbender $INSTALL_DIR/mapbender/http/" >> /etc/apache2/conf.d/mapbender
echo "<Directory $INSTALL_DIR/mapbender/http>" >> /etc/apache2/conf.d/mapbender
echo "Options MultiViews" >> /etc/apache2/conf.d/mapbender
echo "DirectoryIndex index.php" >> /etc/apache2/conf.d/mapbender
echo "Order allow,deny" >> /etc/apache2/conf.d/mapbender
echo "Allow from all" >> /etc/apache2/conf.d/mapbender 
echo "</Directory>" >> /etc/apache2/conf.d/mapbender       

#Create apache2 configuration for mapbender-owsproxy
echo "#Configure apache for mapbender-owsproxy " >> /etc/apache2/conf.d/mapbender
echo "Alias /owsproxy $INSTALL_DIR/mapbender/owsproxy/" >> /etc/apache2/conf.d/mapbender
echo "<Directory $INSTALL_DIR/mapbender/owsproxy>" >> /etc/apache2/conf.d/mapbender
echo "Options MultiViews" >> /etc/apache2/conf.d/mapbender
echo "DirectoryIndex index.php" >> /etc/apache2/conf.d/mapbender
echo "Order allow,deny" >> /etc/apache2/conf.d/mapbender
echo "Allow from all" >> /etc/apache2/conf.d/mapbender 
echo "</Directory>" >> /etc/apache2/conf.d/mapbender   

echo "RedirectMatch ^.*owsproxy.([^i][\w\d]+)\/([\w\d]+)\/?$ http://localhost/owsproxy/http/index.php?sid=$1\&wms=$2\&" >> /etc/apache2/conf.d/mapbender


#Restart apache2 for mapbender
/etc/init.d/apache2 force-reload



#Add Launch icon to desktop
if [ ! -e /usr/share/applications/mapbender.desktop ] ; then
   cat << EOF > /usr/share/applications/mapbender.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapbender
Comment=Mapbender
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/mapbender/
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/mapbender.desktop "$USER_HOME/Desktop/"


echo "Done installing Mapbender"
