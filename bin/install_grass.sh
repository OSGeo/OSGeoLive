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


# this does not attempt to install QGIS-plugin infrastructure, that is
#  done in install_qgis.sh


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

#### install grass ####

PACKAGES="grass grass-doc grass-dev python-opengl python-wxgtk2.8 avce00 \
  e00compr gdal-bin proj-bin python-gdal gpsbabel xml2 sqlitebrowser \
  dbview libtiff-tools python-rpy2 gnuplot"

MODERN_VERSION="6.4"

BUILD_DIR=`pwd`
TMP_DIR=/tmp/build_grass
mkdir "$TMP_DIR"



if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


# Add UbuntuGIS repository (same as QGIS)
cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
#qgis repo 68436DDF unused? :
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  

apt-get update --quiet


apt-get --assume-yes install $PACKAGES

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


INSTALLED_VERSION=`dpkg -s grass | grep '^Version:' | awk '{print $2}' | cut -f1,2 -d.`
IS_OLD_VERSION=`echo "$INSTALLED_VERSION $MODERN_VERSION" | awk '{if ($1 < $2) {print 1} else {print 0} }'`
if [ "$IS_OLD_VERSION" -eq 1 ] ; then
   echo "WARNING: Installed version ($INSTALLED_VERSION) is older than the recommended version ($MODERN_VERSION)."
   echo "         Please fix!"
   #exit 1
fi


#### get sample data ####

# put static data in /usr/local ..
mkdir -p /usr/local/share/grass

# Spearfish dataset, 20mb .tgz
# North Carolina simplified dataset, nc_basic_spm.tar.gz  47mb
## North Carolina dataset, 135mb nc_spm_latest.tar.gz

#avoid mix of old and new datasets
rm -rf /usr/local/share/grass/nc_basic_spm/

for FILE in spearfish_grass60data-0.3 north_carolina/nc_basic_spm ; do
   cd "$TMP_DIR"
   if [ ! -e "$FILE.tar.gz" ] ; then
      # [! -e] bypasses "wget -c" opportunity, oh well
      wget -c --progress=dot:mega \
         "http://grass.osgeo.org/sampledata/$FILE.tar.gz"
   fi

   cd /usr/local/share/grass/
   BASE=`echo "$FILE" | sed -e 's+.*/++'`
   tar xzf "$TMP_DIR/$BASE.tar.gz"

   #if [ $? -eq 0 ] ; then
   #   \rm "$TMP_DIR/$FILE.tar.gz"
   #fi
done

#minor cleanup and rearrangement
mv /usr/local/share/grass/nc_basic_spm/gisdemo_ncspm/* \
   /usr/local/share/grass/nc_basic_spm/
rmdir /usr/local/share/grass/nc_basic_spm/gisdemo_ncspm
# remove some cruft
rm -f /usr/local/share/grass/nc_basic_spm/.[D_]*


# but link into $HOME for easy access & so user owns mapset
mkdir "$USER_HOME/grassdata"
cd "$USER_HOME/grassdata"

for LOCATION in spearfish60 nc_basic_spm ; do
   mkdir "$LOCATION"
   ln -s "/usr/local/share/grass/$LOCATION/PERMANENT" "$LOCATION/"
   mkdir "$LOCATION/user1"
   cp "/usr/local/share/grass/$LOCATION/user1"/* "$LOCATION/user1/"

   # PERMANENT can be read-only
   # are we the owner of the symlinked PERMANENT? (yes) We don't have
   #  to be but it would be nice. otherwise libgis enforces read-only.
   chmod -R a+rX /usr/local/share/grass/$LOCATION
   chown -R root.users /usr/local/share/grass/$LOCATION
done

# link in an extra mapset with satellite data
#ln -s /usr/local/share/grass/nc_spm_08/landsat \
#      "$USER_HOME"/grassdata/nc_spm_08/landsat

adduser $USER_NAME users
chown -R $USER_NAME.$USER_NAME "$USER_HOME/grassdata"

# copy into /etc/skel too
cp -r "$USER_HOME/grassdata" /etc/skel/
chown -R root.root /etc/skel/grassdata


### Bug #868: QGIS: Permissions on GRASS LOCATIONS ###
#  -- Crappy workaround --
# QGIS can't handle multi-user GRASS locations, so to get the quickstart
# examples to work well we need to change the file ownership of PERMANENT
# to the user.  We do this at boot time to allow the end-user to easily
# disable it if they want something more sane or create another user acc't.
if [ `grep -c 'grass.*/PERMANENT' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local
    echo "chown $USER_NAME /usr/local/share/grass/spearfish60/PERMANENT" >> /etc/rc.local
    echo "chown $USER_NAME /usr/local/share/grass/nc_basic_spm/PERMANENT" >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi
######



#### preconfig setup ####

GRASS_GUI=wxpython

cat << EOF > "$USER_HOME/.grassrc6"
GISDBASE: $USER_HOME/grassdata
LOCATION_NAME: spearfish60
MAPSET: user1
GRASS_GUI: $GRASS_GUI
EOF


chown -R $USER_NAME.$USER_NAME "$USER_HOME/.grassrc6"

mkdir -p "$USER_HOME/grassdata/addons"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/grassdata/addons"


if [ `grep -c 'GRASS_PAGER=' "$USER_HOME/.profile"` -eq 0 ] ; then
   cat << EOF >> "$USER_HOME/.profile"

GRASS_PAGER=more
GRASS_ADDON_PATH=~/grassdata/addons
export GRASS_PAGER GRASS_ADDON_PATH

EOF
fi


#copy over prebuilt font list
cp -f "$BUILD_DIR"/../app-conf/grass/fontcap /usr/lib/grass64/etc/

#and let it be overwritten
chmod g+w /usr/lib/grass64/etc/fontcap
chgrp users /usr/lib/grass64/etc/fontcap


#### install desktop icon ####
if [ ! -e "/usr/share/icons/grass-48x48.png" ] ; then
   wget -nv "http://svn.osgeo.org/grass/grass/trunk/gui/icons/grass-48x48.png"
   \mv grass-48x48.png /usr/share/icons/
fi


GVER=`echo "$INSTALLED_VERSION" | sed -e 's/\.//'`

#if [ ! -e /usr/share/applications/grass.desktop ] ; then
   cat << EOF > /usr/share/applications/grass.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=GRASS GIS
Comment=GRASS GIS $INSTALLED_VERSION
Categories=Application;Education;Geography;
Exec=/usr/bin/grass$GVER
Icon=/usr/share/icons/grass-48x48.png
Terminal=true
EOF
#fi

cp /usr/share/applications/grass.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/grass.desktop"


# add menu item
if [ ! -e /usr/share/menu/grass ] ; then
   cat << EOF > /usr/share/menu/grass
?package(grass):needs="text"\
  section="Applications/Science/Geoscience"\
  title="GRASS GIS"\
  command="/usr/bin/grass$GVER"\
  icon="/usr/share/icons/grass-48x48.png"
EOF

   update-menus
fi


echo "Finished installing GRASS $INSTALLED_VERSION."

