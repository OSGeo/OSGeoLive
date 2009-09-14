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

#Add repositories
wget -r https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

#Add signed key for repositorys LTS and non-LTS
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  

apt-get update

#Install packages
apt-get --assume-yes install qgis=1.3.0-1~jaunty3 \
   qgis-common qgis-plugin-grass python-qgis python-qgis-common \
   qgis-plugin-grass-common libgdal1-1.6.0-grass gpsbabel grass-doc


#Turned off assuming the repo conflict will be resolved
#apt-get --assume-yes install libgdal1-1.6.0 
##libgdal1-1.6.0-grass

#Install optional packages that some plugins use
apt-get --assume-yes python-psycopg2 python-qwt5-qt4

#Make sure old qt uim isn't installed
apt-get remove uim-qt uim-qt3


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
fi
update-menus


#TODO Install some popular python plugins
#Use wget to pull them directly into qgis python path?

#TODO Include some sample projects using already installed example data
#post a sample somewhere on qgis website or launchpad to pull

echo "Finished installing QGIS $INSTALLED_VERSION."
