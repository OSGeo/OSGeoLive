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
# This script will install Quantum GIS including python and GRASS support, assumes script is run with sudo priveleges. NOTE: Untested, I don't know the sudo password for the VM

# Running:
# =======
# qgis

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_qgis
BUILD_DIR=`pwd`

#Add repositories
cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  

apt-get update

#Install packages
apt-get --assume-yes install qgis \
   qgis-common qgis-plugin-grass python-qgis python-qgis-common \
   qgis-plugin-grass-common gpsbabel grass-doc
#libgdal1-1.7.0-grass - possibly not needed anymore since qgis-plugin-grass will pull the correct one?

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


#Install optional packages that some plugins use
apt-get --assume-yes install python-psycopg2 \
   python-gdal python-matplotlib python-qt4-sql \
   libqt4-sql-psql python-qwt5-qt4


#Make sure old qt uim isn't installed
apt-get --assume-yes remove uim-qt uim-qt3


#### install desktop icon ####
INSTALLED_VERSION=`dpkg -s qgis | grep '^Version:' | awk '{print $2}' | cut -f1 -d~`
if [ ! -e /usr/share/applications/qgis.desktop ] ; then
   cat << EOF > /usr/share/applications/qgis.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Quantum GIS
Comment=QGIS $INSTALLED_VERSION
Categories=Application;Education;Geography;
Exec=/usr/bin/qgis %F
Icon=/usr/share/icons/qgis-icon.xpm
Terminal=false
StartupNotify=false
Categories=Education;Geography;Qt;
MimeType=application/x-qgis-project;image/tiff;image/jpeg;image/jp2;application/x-raster-aig;application/x-mapinfo-mif;application/x-esri-shape;
EOF
fi

cp /usr/share/applications/qgis.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qgis.desktop"


# add menu item
if [ ! -e /usr/share/menu/qgis ] ; then
   cat << EOF > /usr/share/menu/qgis
?package(qgis):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="Quantum GIS"\
  command="/usr/bin/qgis"\
  icon="/usr/share/icons/qgis-icon.xpm"
EOF
  update-menus
fi


#Install the Manual and Intro guide locally and link them to the description.html
mkdir /usr/local/share/qgis
wget -c --progress=dot:mega http://download.osgeo.org/qgis/doc/manual/qgis-1.0.0_a-gentle-gis-introduction_en.pdf \
	--output-document=/usr/local/share/qgis/qgis-1.0.0_a-gentle-gis-introduction_en.pdf
wget -c --progress=dot:mega http://download.osgeo.org/qgis/doc/manual/qgis-1.3.0_user_guide_en.pdf \
	--output-document=/usr/local/share/qgis/qgis-1.3.0_user_guide_en.pdf

chmod 644 /usr/local/share/qgis/*.pdf


if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

echo "FIXME: use $TMP_DIR not /tmp/"

#TODO Install some popular python plugins
#Use wget to pull them directly into qgis python path?
# A temp bundle of common plugins

# be careful with 'wget -c', if the file changes on the server the local
# copy will get corrupted. Wget only knows about filesize, not file 
# contents, timestamps, or md5sums!
DATAURL="http://www.geofemengineering.it/data/plugins.tar.gz"

wget --progress=dot:mega "$DATAURL" \
     --output-document=/tmp/qgis_plugin.tar.gz

tar xzf /tmp/qgis_plugin.tar.gz  -C /tmp
cp -R  /tmp/.qgis/python/plugins/ /usr/share/qgis/python/

#Next line might be optional, unsure
#chmod -R 777 /usr/share/qgis/python/plugins/*
# why 777 and not 644? if you want recursive subdirs +x use +X to only +x for directories.
#   - might not necessary at all

#TODO Include some sample projects using already installed example data
#post a sample somewhere on qgis website or launchpad to pull
cp "$BUILD_DIR/../app-data/qgis/QGIS-Itasca-Example.qgs" /usr/local/share/qgis/
cp "$BUILD_DIR/../app-data/qgis/QGIS-Grass-Example.qgs" /usr/local/share/qgis/
cp "$BUILD_DIR/../app-data/qgis/QGIS-NaturalEarth-Example.qgs" /usr/local/share/qgis/

chmod 644 /usr/local/share/qgis/*.qgs

#add a connection for postgis if it's installed
QGIS_CONFIG="/home/$USER_NAME/.config/QuantumGIS/QGIS.conf"
if [ -e "$QGIS_CONFIG" ] && \
   [ `grep -c '\[PostgreSQL\]' "$QGIS_CONFIG"` -eq 0 ] ; then
	cat >> "/home/$USER_NAME/.config/QuantumGIS/QGIS.conf" <<EOF

[PostgreSQL]
connections\selected=local
connections\local\host=localhost
connections\local\database=postgres
connections\local\port=5432
connections\local\username=user
connections\local\password=user
connections\local\publicOnly=false
connections\local\geometryColumnsOnly=false
connections\local\save=true
EOF
fi

echo "Finished installing QGIS $INSTALLED_VERSION."
