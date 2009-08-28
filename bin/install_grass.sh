#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install GRASS GIS
#    written by H.Bowman <hamish_b  yahoo com>
#    GRASS homepage: http://grass.osgeo.org/


# this does not attempt to install QGIS-plugin infrastructure, that should
# be done in another script.


#### install grass ####

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


PACKAGES="grass grass-doc avce00 e00compr gdal-bin gpsbabel more"

MODERN_VERSION="6.4"

# For GRASS 6.4 on Ubuntu 9.04 you will need to add Jachym's unofficial
#  repo to /etc/sources.list.
# See http://les-ejk.cz/2009/05/grass-64-rc4-for-ubuntu-904/


TO_INSTALL=""
for PACKAGE in $PACKAGES ; do
   if [ `dpkg -l $PACKAGE | grep -c '^ii'` -eq 0 ] ; then
      TO_INSTALL="$TO_INSTALL $PACKAGE"
   fi
done

if [ -n "$TO_INSTALL" ] ; then
   apt-get --assume-yes install $TO_INSTALL

   if [ $? -ne 0 ] ; then
      echo "ERROR: package install failed: $TO_INSTALL"
      #exit 1
   fi
fi

INSTALLED_VERSION=`dpkg -s grass | grep '^Version:' | awk '{print $2}' | cut -f1,2 -d.`
IS_OLD_VERSION=`echo "$INSTALLED_VERSION $MODERN_VERSION" | awk '{if ($1 < $2) {print 1} else {print 0} }'`
if [ "$IS_OLD_VERSION" -eq 1 ] ; then
   echo "WARNING: Installed version ($INSTALLED_VERSION) is older than the recommended version ($MODERN_VERSION)."
   echo "         Please fix!"
   #exit 1
fi


#### get sample data ####

if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


# put static data in /usr/local ..
mkdir -p /usr/local/share/grass
cd /usr/local/share/grass/

# Spearfish dataset, 20mb .tgz
# North Carolina dataset, 135mb .tgz
for FILE in spearfish_grass60data-0.3 nc_spm_latest ; do
   wget -nv http://grass.osgeo.org/sampledata/$FILE.tar.gz

   tar xzf $FILE.tar.gz

   if [ $? -eq 0 ] ; then
      \rm $FILE.tar.gz
   fi
done

# but link into $HOME for easy access & so user owns mapset
mkdir "$USER_HOME/grassdata"
cd "$USER_HOME/grassdata"

for LOCATION in spearfish60 nc_spm_08 ; do
   mkdir $LOCATION
   ln -s /usr/local/share/grass/$LOCATION/PERMANENT PERMANENT
   mkdir $LOCATION/user1
   cp /usr/local/share/grass/$LOCATION/user1/* $LOCATION/user1/

   chmod g+rwx /usr/local/share/grass/$LOCATION
   chown root.users /usr/local/share/grass/$LOCATION
done

adduser $USER_NAME users
chown -R $USER_NAME.$USER_NAME "$USER_HOME/grassdata"


#### preconfig setup ####

if [ "$IS_OLD_VERSION" -eq 1 ] ; then
   GRASS_GUI=tcltk
else
   GRASS_GUI=wxpython
fi

cat << EOF > "$USER_HOME/.grassrc6"
GISDBASE: $USER_HOME/grassdata
LOCATION_NAME: spearfish60
MAPSET: user1
GRASS_GUI: $GRASS_GUI
EOF
chown -R $USER_NAME.$USER_NAME "$USER_HOME/.grassrc6"

mkdir -p "$USER_HOME/grassdata/addons"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/grassdata/addons"

if [ `grep -c 'GRASS_PAGER=' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   cat << EOF >> "$USER_HOME/.bashrc"

GRASS_PAGER=more
GRASS_ADDON_PATH=~/grassdata/addons
export GRASS_PAGER GRASS_ADDON_PATH

EOF
fi


#### install desktop icon ####
if [ ! -e "/usr/share/icons/grass-48x48.png" ] ; then
   wget -nv "http://svn.osgeo.org/grass/grass/trunk/gui/icons/grass-48x48.png"   \mv grass64.xpm /usr/share/icons/
   \mv grass-48x48.png /usr/share/icons/
fi

cat << EOF > "$USER_HOME/Desktop/grass.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=GRASS GIS
Comment=GRASS GIS $INSTALLED_VERSION
Categories=Application
Exec=/usr/bin/grass
Icon=/usr/share/icons/grass-48x48.png
Terminal=true
EOF

chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/grass.desktop"



echo "Finished installing GRASS $INSTALLED_VERSION."
