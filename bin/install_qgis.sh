#!/bin/sh
#############################################################################
#
# Purpose: This script will install QGIS including Python and GRASS support,
#
#############################################################################
# Copyright (c) 2009-2023 The Open Source Geospatial Foundation and others.
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

TMP_DIR=/tmp/build_qgis

if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

apt-get -q update

#Install packages
apt-get --assume-yes install qgis \
   qgis-common python3-qgis python3-qgis-common \
   gpsbabel qgis-plugin-grass


if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

# Install plugins
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/qgis/qgis3-osgeolive15-plugins.zip"
unzip -q qgis3-osgeolive15-plugins.zip -d /
rm -rf qgis3-osgeolive15-plugins.zip

#### install desktop icon ####
INSTALLED_VERSION=`dpkg -s qgis | grep '^Version:' | awk '{print $2}' | cut -f1 -d~`
if [ ! -e /usr/share/applications/org.qgis.qgis.desktop ] ; then
   cat << EOF > /usr/share/applications/org.qgis.qgis.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=QGIS
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

cp /usr/share/applications/org.qgis.qgis.desktop "$USER_HOME/Desktop/qgis.desktop"
# cp /usr/share/applications/qbrowser.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qgis.desktop"
# chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qbrowser.desktop"


# add menu item
if [ ! -e /usr/share/menu/qgis ] ; then
   cat << EOF > /usr/share/menu/qgis
?package(qgis):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="QGIS"\
  command="/usr/bin/qgis"\
  icon="/usr/share/icons/qgis-icon.xpm"
EOF
  update-menus
fi


# Install the Manual and Intro guide locally and link them to the description.html
mkdir /usr/local/share/qgis

# any pdf version of the intro guide?
#  http://docs.qgis.org/2.2/en/docs/gentle_gis_introduction
#wget -c --progress=dot:mega \
#        "http://download.osgeo.org/qgis/doc/manual/qgis-1.0.0_a-gentle-gis-introduction_en.pdf" \
#	--output-document=/usr/local/share/qgis/qgis-1.0.0_a-gentle-gis-introduction_en.pdf

# TODO: Consider including translations. New version is available but size is 140MB...
# https://docs.qgis.org/2.18/pdf/en/
# Links to very old tutorial files
#VER=2.8
#DOCURL="http://download.osgeo.org/livedvd/data/qgis"
#for DOC in UserGuide QGISTrainingManual ; do
#   wget -c --progress=dot:mega \
#       "$DOCURL/QGIS-$VER-$DOC-en.pdf" \
#	--output-document="/usr/local/share/qgis/QGIS-$VER-$DOC-en.pdf"
#done

#chmod 644 /usr/local/share/qgis/*.pdf


# Install tutorials
# Todo links to very old tutorial
#wget --progress=dot:mega \
#    "https://github.com/qgis/osgeo-live-qgis-tutorials/tarball/master" \
#     --output-document="$TMP_DIR"/tutorials.tgz

#tar xzf "$TMP_DIR"/tutorials.tgz -C "$TMP_DIR"

#cd "$TMP_DIR"/*QGIS-OSGEO-Live-Tutorials*

#apt-get --assume-yes install python-sphinx
#make html
#cp -R _build/html /usr/local/share/qgis/tutorials

# # Install some popular python plugins
# 
# # be careful with 'wget -c', if the file changes on the server the local
# # copy will get corrupted. Wget only knows about filesize, not file 
# # contents, timestamps, or md5sums!
# 
# DATAURL="http://download.osgeo.org/livedvd/data/qgis/qgis-plugins-7.0.tar.gz"
# 
# #TODO use a python script and the QGIS API to pull these within QGIS from online repo
# mkdir -p "$TMP_DIR"/plugins
# 
# wget --progress=dot:mega "$DATAURL" \
#      --output-document="$TMP_DIR"/qgis_plugin.tar.gz
# 
# tar xzf "$TMP_DIR"/qgis_plugin.tar.gz  -C "$TMP_DIR/plugins"
# #cp -R  "$TMP_DIR"/.qgis/python/plugins/ /usr/share/qgis/python/
# cp -R  "$TMP_DIR"/plugins/ /usr/share/qgis/python/
# chmod -R 755 /usr/share/qgis/python


#TODO Include some sample projects using already installed example data
#post a sample somewhere on qgis website or launchpad to pull
cp "$BUILD_DIR/../app-data/qgis/QGIS-Itasca-Example.qgz" /usr/local/share/qgis/
#borked: cp "$BUILD_DIR/../app-data/qgis/QGIS-Grass-Example.qgs" /usr/local/share/qgis/
cp "$BUILD_DIR/../app-data/qgis/QGIS-NaturalEarth-Example.qgz" /usr/local/share/qgis/

chmod -R 775 /usr/local/share/qgis
chown -R root:users /usr/local/share/qgis
#Link example to the home directory
ln -s /usr/local/share/qgis "$USER_HOME"/qgis-examples
ln -s /usr/local/share/qgis /etc/skel/qgis-examples


#add a connection for postgis if it's installed
QGIS_CONFIG_PATH="$USER_HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/"

mkdir -p "$QGIS_CONFIG_PATH"
cp "$BUILD_DIR/../app-conf/qgis/QGIS3.ini" "$QGIS_CONFIG_PATH"

chmod 644 "$USER_HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
chown $USER_NAME.$USER_NAME "$USER_HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"

# set up some extra PostGIS and Spatialite DBs
CONFFILE="$USER_HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
TMPFILE=`tempfile`
USR=user
PSWD=user

DBS="
52nSOS
eoxserver_demo"
#disabled:
# pgrouting
#v2.2_mapfishsample
# osm_local_smerc
# cartaro

cat << EOF > "$TMPFILE"
[SpatiaLite]
connections\\selected=trento.sqlite
connections\\trento.sqlite\\sqlitepath=/usr/local/share/data/spatialite/trento.sqlite

EOF

cat << EOF >> "$TMPFILE"
[PostgreSQL]
connections\selected=OpenStreetMap
EOF


for DBNAME in $DBS ; do
   cat << EOF >> "$TMPFILE"
connections\\$DBNAME\\service=
connections\\$DBNAME\\host=localhost
connections\\$DBNAME\\database=$DBNAME
connections\\$DBNAME\\port=5432
connections\\$DBNAME\\username=$USR
connections\\$DBNAME\\password=$PSWD
connections\\$DBNAME\\publicOnly=false
connections\\$DBNAME\\allowGeometrylessTables=false
connections\\$DBNAME\\sslmode=1
connections\\$DBNAME\\saveUsername=true
connections\\$DBNAME\\savePassword=true
connections\\$DBNAME\\estimatedMetadata=false
EOF
done

tail -n +3 "$CONFFILE" > "$TMPFILE".b
cat "$TMPFILE" "$TMPFILE".b > "$CONFFILE"
rm -f "$TMPFILE" "$TMPFILE".b


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
