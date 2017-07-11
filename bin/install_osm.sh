#!/bin/sh
# Copyright (c) 2009-2017 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
#
# This script is free software; you can redistribute it and/or modify it
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
# This script will install some OpenStreetMap utilities

# Running:
# =======
# sudo ./install_osm.sh

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_osm


if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

mkdir /usr/local/share/osm

apt-get install --assume-yes josm gpsd gpsd-clients \
   xmlstarlet imposm osmosis python-osmapi \
   osmctools osmium-tool nik4


##-----------------------------------------------
## JOSM -- OpenStreetMap feature editor
# see also  http://josm.openstreetmap.de/wiki/Download#Ubuntu

# pre-seed the josmrc file to make the default window size fit on a smaller display
mkdir -p "$USER_HOME"/.josm

cat << EOF > "$USER_HOME"/.josm/preferences
gui.geometry=800x600+40+40
gui.maximized=false
EOF

cd "$TMP_DIR"
wget -c --tries=3 --progress=dot:mega \
    "http://download.osgeo.org/livedvd/10.0/josm/josm_plugs.tar.bz2"
    
## TODO bail on err
curl http://download.osgeo.org/livedvd/10.0/josm/josm_plugs.tar.bz2.sha1 | sha1sum --check -

tar xf josm_plugs.tar.bz2
mkdir -p "$USER_HOME"/.josm/plugins
mv *jar "$USER_HOME"/.josm/plugins/

chown $USER_NAME.$USER_NAME "$USER_HOME"/.josm -R

#### desktop icons
echo "MimeType=application/x-openstreetmap+xml;" \
   >> /usr/share/applications/josm.desktop
echo '#!/usr/bin/env xdg-open' > "$USER_HOME"/Desktop/josm.desktop
cat /usr/share/applications/josm.desktop >> "$USER_HOME"/Desktop/josm.desktop
chmod a+x "$USER_HOME"/Desktop/josm.desktop

# add an icon for viewing The Map online
mkdir -p /usr/local/share/applications

MAP_CENTER="lat=42.3743935&lon=-71.1184512"
MARKER="mlat=42.3743935&mlon=-71.1184512"
ZOOM="16"

cat << EOF > /usr/local/share/applications/osm_online.desktop
[Desktop Entry]
Name=View OSM online
Comment=Opens a web browser to The Map
Exec=firefox "http://www.openstreetmap.org/?$MAP_CENTER&zoom=$ZOOM&$MARKER"
Icon=josm-32
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;
EOF
chmod a+x /usr/local/share/applications/osm_online.desktop
cp /usr/local/share/applications/osm_online.desktop "$USER_HOME/Desktop/"


#########################################################################
#### install sample OSM data
CITY="Boston_MA"
BBOX="-71.10,42.31628,-70.995,42.39493"

# visualize: (FIXME!)
#http://www.openstreetmap.org/?box=yes&bbox=$BBOX

# Perhaps it is too detailed a city for some of our examples, so we
#  provide a smaller version too:
#CITY="Portland_OR_CBD"
#BBOX="-122.721,45.488,-122.620,45.544"
#
#
# City OSM data:
#  Having a sample .osm file around will benefit many applications. In addition
#  to JOSM and Gosmore, QGIS and Mapnik can also render .osm directly.
#
# We should also push the .osm file into postgis/postgres with osm2pgsql.
#   todo: perhaps try 'imposm' instead:
#         http://imposm.org/docs/imposm/latest/
#
# $ createdb -T template_postgis osm_$CITY
# $ osm2pgsql -d osm_$CITY $CITY.osm
#

### Please update to latest data at the last minute! See data dir on server for details.
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/osm/$CITY/$CITY.osm.bz2"

wget -c --tries=3 --progress=dot:mega \
   -O /usr/local/share/osm/sample.osm \
   "http://learnosm.org/files/sample.osm"

#download as part of disc build process
# Downloading from the osmxapi takes me about 6 minutes and is around 20MB.
# hypercube is near the OSGeo servers at SDSC so should be much faster.

# Xapi is dying,
#   http://thread.gmane.org/gmane.comp.gis.openstreetmap/56097/
# long live Xapi,
#   https://github.com/iandees/xapi-servlet
# for our simple "planet extract" needs, maybe OSM3S would be a better fit anyway?
#   http://wiki.openstreetmap.org/wiki/OSM3S/install
#   http://www.overpass-api.de/

if [ ! -e "$CITY.osm.bz2" ] ; then
  #XAPI_URL="http://xapi.openstreetmap.org/api/0.6/"
  #XAPI_URL="http://open.mapquestapi.com/xapi/api/0.6/"
  #XAPI_URL="http://jxapi.openstreetmap.org/xapi/api/0.6/"
  # Overpass server with Xapi compatibility layer
  XAPI_URL="http://www.overpass-api.de/api/xapi?"
  # needed for Overpass server:
  XAPI_EXTRA="[@meta]"

  wget --progress=dot:mega -O "$CITY.osm" \
       "${XAPI_URL}*[bbox=$BBOX]$XAPI_EXTRA"
  if [ $? -ne 0 ] ; then
     echo "ERROR getting osm data"
     exit 1
  fi
  bzip2 "$CITY.osm"
fi


cp -f "$CITY.osm.bz2" /usr/local/share/osm/
mkdir -p /usr/local/share/data/osm --verbose
ln -s /usr/local/share/osm/"$CITY.osm.bz2" /usr/local/share/data/osm/
ln -s /usr/local/share/data/osm/"$CITY.osm.bz2" \
   /usr/local/share/data/osm/feature_city.osm.bz2

####
# Smaller extract for pgRouting examples
#wget -N --progress=dot:mega \
#   "http://download.osgeo.org/livedvd/data/osm/$CITY/${CITY}_CBD.osm.bz2"
#cp -f "${CITY}_CBD.osm.bz2" /usr/local/share/osm/
#ln -s /usr/local/share/osm/${CITY}_CBD.osm.bz2 /usr/local/share/data/osm
#ln -s /usr/local/share/data/osm/"${CITY}_CBD.osm.bz2" \
#   /usr/local/share/data/osm/feature_city_CBD.osm.bz2


# To make the sqlite POI db, use osm2poidb from GpsDrive utils,
#bzcat $CITY.osm.bz2 | osm2poidb -o ${CITY}_poi.db STDIN
#bzip2 ${CITY}_poi.db


###########################
#### testing for osm2pgsql 0.8x
apt-get --assume-yes --no-install-recommends install osm2pgsql

#
# ### Make hi-res OSM coastline a shapefile polygon for Mapnik rendering
#
# # Xapi OSM extractor:  http://wiki.openstreetmap.org/wiki/Xapi
# wget -O barcelona_coastline.osm \
#    "http://osmxapi.hypercube.telascience.org/api/0.6/way[natural=coastline][bbox=1.5,41.0,2.5,41.75]"
#
# # GRASS GIS commands to turn the .osm coastline segment into a closed shapefile polygon
# v.in.gpsbabel -r in=barcelona_coastline.osm format=osm \
#   out=barcelona_coastline
#
# eval `v.info -g barcelona_coastline`
#  north=41.562324
#  south=41.163893
#  east=2.515893
#  west=1.462335
#
# echo "
# L 4
#  $west $south
#  $west 41.75
#  $east 41.75
#  $east $north
# " | v.in.ascii -n format=standard out=barcelona_ul_box --o
#
# v.patch in=barcelona_coastline,barcelona_ul_box out=barcelona_coastline_box1
# v.type in=barcelona_coastline_box1 out=barcelona_coastline_box2 type=line,boundary
# v.centroids in=barcelona_coastline_box2 out=barcelona_coastline_box
# g.remove v=barcelona_coastline_box1,barcelona_coastline_box2
#
# v.out.ogr -c in=barcelona_coastline_box dsn=barcelona_coastline_box type=area
#
# tar czf barcelona_coastline_box.tgz barcelona_coastline_box/
#
#FILE="barcelona_coastline_box.tgz"
#wget -N --progress=dot "http://download.osgeo.org/livedvd/data/osm/$FILE"
#tar xzf "$FILE"
#mv `basename $FILE .tgz` /usr/local/share/osm/
#ln -s /usr/local/share/osm/`basename $FILE .tgz` /usr/local/share/data/osm


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
