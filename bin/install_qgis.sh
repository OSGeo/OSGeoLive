#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install Quantum GIS including python and GRASS support,
#  assumes script is run with sudo priveleges.

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

#CAUTION: UbuntuGIS should be enabled only through setup.sh
#Add repositories
#cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get -q update

#Install packages
## 23feb14 fix for QGis "can't make bookmarks"
apt-get --assume-yes install qgis \
   qgis-common python-qgis python-qgis-common \
   gpsbabel python-rpy2 python-qt4-phonon \
   libqt4-sql-sqlite


if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


# add pykml needed by qgis-plugin 'geopaparazzi'
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/ossim/pykml_0.1.1-1_all.deb"
gdebi --non-interactive --quiet pykml_0.1.1-1_all.deb


#Install optional packages that some plugins use
apt-get --assume-yes install python-psycopg2 \
   python-gdal python-matplotlib python-qt4-sql \
   libqt4-sql-psql python-qwt5-qt4 python-tk \
   python-sqlalchemy python-owslib python-shapely

# Install plugins
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/qgis/python-qgis-osgeolive_9.0-1_all.deb"
dpkg -i python-qgis-osgeolive_9.0-1_all.deb
rm -rf python-qgis-osgeolive_9.0-1_all.deb

#Install optional packages for workshops
apt-get --assume-yes install qt4-designer \
   pyqt4-dev-tools

#Make sure old qt uim isn't installed
apt-get --assume-yes remove uim-qt uim-qt3

###FIXME: Temp patch for #1466
wget -c --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/grass/grass7.tar.gz"
tar zxvf grass7.tar.gz
rm grass7.tar.gz
cp -r grass7/* /usr/share/qgis/python/plugins/processing/algs/grass7/
rm -rf grass7

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
else
   sed -i -e 's/^Name=QGIS Desktop/Name=QGIS/' \
      /usr/share/applications/qgis.desktop
fi

cp /usr/share/applications/qgis.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/qbrowser.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qgis.desktop"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/qbrowser.desktop"


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


# Install the Manual and Intro guide locally and link them to the description.html
mkdir /usr/local/share/qgis
# any pdf version of the intro guide?
#  http://docs.qgis.org/2.2/en/docs/gentle_gis_introduction
#wget -c --progress=dot:mega \
#        "http://download.osgeo.org/qgis/doc/manual/qgis-1.0.0_a-gentle-gis-introduction_en.pdf" \
#	--output-document=/usr/local/share/qgis/qgis-1.0.0_a-gentle-gis-introduction_en.pdf

# TODO: Consider including translations
VER=2.8
DOCURL="http://docs.qgis.org/$VER/pdf/en"
for DOC in UserGuide QGISTrainingManual ; do
   wget -c --progress=dot:mega \
       "$DOCURL/QGIS-$VER-$DOC-en.pdf" \
	--output-document="/usr/local/share/qgis/QGIS-$VER-$DOC-en.pdf"
done

chmod 644 /usr/local/share/qgis/*.pdf


# Install tutorials
wget --progress=dot:mega \
    "https://github.com/qgis/osgeo-live-qgis-tutorials/tarball/master" \
     --output-document="$TMP_DIR"/tutorials.tgz

tar xzf "$TMP_DIR"/tutorials.tgz -C "$TMP_DIR"

cd "$TMP_DIR"/*osgeo-live-qgis-tutorials*

apt-get --assume-yes install python-sphinx
make html
cp -R _build/html /usr/local/share/qgis/tutorials

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
cp "$BUILD_DIR/../app-data/qgis/QGIS-Itasca-Example.qgs" /usr/local/share/qgis/
#borked: cp "$BUILD_DIR/../app-data/qgis/QGIS-Grass-Example.qgs" /usr/local/share/qgis/
cp "$BUILD_DIR/../app-data/qgis/QGIS-NaturalEarth-Example.qgs" /usr/local/share/qgis/

chmod 664 /usr/local/share/qgis/*.qgs
chgrp users /usr/local/share/qgis/*.qgs
#Link example to the home directory
ln -s /usr/local/share/qgis "$USER_HOME"/qgis-examples
ln -s /usr/local/share/qgis /etc/skel/qgis-examples


#add a connection for postgis if it's installed
QGIS_CONFIG_PATH="$USER_HOME/.config/QGIS/"

mkdir -p "$QGIS_CONFIG_PATH"
cp "$BUILD_DIR/../app-conf/qgis/QGIS2.conf" "$QGIS_CONFIG_PATH"

chmod 644 "$USER_HOME/.config/QGIS/QGIS2.conf"
chown $USER_NAME.$USER_NAME "$USER_HOME/.config/QGIS/QGIS2.conf"


# set up some extra PostGIS and Spatialite DBs
CONFFILE="$USER_HOME/.config/QGIS/QGIS2.conf"
TMPFILE=`tempfile`
USR=user
PSWD=user

DBS="
52nSOS
cartaro
eoxserver_demo
pgrouting"
#disabled:
#v2.2_mapfishsample
# osm_local_smerc

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
