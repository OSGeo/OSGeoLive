#!/bin/sh
# Copyright (c) 2009-2013 by Hamish Bowman, and the Open Source Geospatial Foundation
# Licensed under the GNU LGPL version >= 2.1.
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
# script to install GpsDrive
#    written by H.Bowman <hamish_b  yahoo com>
#    GpsDrive homepage: http://www.gpsdrive.de
#

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_gpsdrive.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_gpsdrive.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

## same as install_osm.sh def
CITY="SanMateo_CA"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_gpsdrive


#### install program ####
####  (postgresql is installed once, system-wide
####   so do not repeat the PG install here)

PACKAGES="gpsd gpsd-clients python-gps \
   espeak gdal-bin gpsbabel \
   graphicsmagick-imagemagick-compat \
   python-mapnik \
   speech-dispatcher \
   openstreetmap-map-icons-square \
   openstreetmap-map-icons-scalable \
   openstreetmap-map-icons-classic \
   ttf-dejavu \
   wget netpbm optipng \
   sqlite3 sqlitebrowser"

apt-get --assume-yes install $PACKAGES

if [ $? -ne 0 ] ; then
   echo "An error occurred installing packages. Aborting install."
   exit 1
fi


#######################
## use prebuilt debs

if [ ! -d "$TMP_DIR" ] ; then
  mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

URL="http://download.osgeo.org/livedvd/data/gpsdrive/trusty/$ARCH"
VER="2.12+svn2726-1"
MAIN_FILE="gpsdrive_${VER}_${ARCH}.deb"
EXTRA_FILES="
  gpsdrive-data_${VER}_all.deb
  gpsdrive-friendsd_${VER}_${ARCH}.deb
  gpsdrive-utils_${VER}_${ARCH}.deb"

wget -c --progress=dot:mega "$URL/$MAIN_FILE"
for FILE in $EXTRA_FILES ; do
   wget -c -nv "$URL/$FILE"
done

gdebi --non-interactive --quiet gpsdrive-data_${VER}_all.deb
gdebi --non-interactive --quiet gpsdrive-friendsd_${VER}_${ARCH}.deb
gdebi --non-interactive --quiet gpsdrive-utils_${VER}_${ARCH}.deb
gdebi --non-interactive --quiet gpsdrive_${VER}_${ARCH}.deb



#### install data ####

mkdir /etc/skel/.gpsdrive
mkdir "$USER_HOME/.gpsdrive"

# program defaults
cat << EOF > "/etc/skel/.gpsdrive/gpsdriverc"
lastlong = -122.3
lastlat  =  37.5
scalewanted = 10000
dashboard_3 = 12
autobestmap = 0
mapnik = 1
mapnik_caching = 0
minsecmode = 2
friendsname = LiveDVD
showbutton_trackrestart = 0
showbutton_trackclear = 0
icon_theme = classic.small
osmdbfile = /usr/local/share/osm/${CITY}_poi.db
mapnik_postgis_dbname = osm_local
EOF

cp /etc/skel/.gpsdrive/gpsdriverc "$USER_HOME/.gpsdrive/"


# add any waypoints you want to see displayed
cat << EOF > "/etc/skel/.gpsdrive/way.txt"
Sydney_Convention_Centre        -33.8750   151.2005
Barcelona_Convention_Centre      41.3724     2.1518
FOSS4G_2011_(Sheraton_Denver)    39.74251 -104.9891
OSM_State_of_the_Map_2011        39.7457  -105.0034
Business_School_South_(Jubilee)  52.9517  -1.1864
East_Midlands_Conference_Centre  52.9390  -1.2032
FOSS4G-NA_2013_(Marriott_City_Center)   44.9776  -93.2735
Oregon_Convention_Center         45.5281  -122.6632
Portland_State_University        45.5121  -122.6828
EOF

cp /etc/skel/.gpsdrive/way.txt "$USER_HOME/.gpsdrive/"


#download latest OSM POIs for host city
#wget -N --progress=dot:mega  http://poi.gpsdrive.de/$COUNTRY.db.bz2
wget -N --progress=dot:mega \
  "http://download.osgeo.org/livedvd/data/osm/$CITY/${CITY}_poi.db.bz2"
bzip2 -d "${CITY}_poi.db.bz2"
mkdir -p /usr/local/share/osm/
mkdir -p /usr/local/share/data/osm/
mv "${CITY}_poi.db" /usr/local/share/osm/
ln -s /usr/local/share/osm/"${CITY}_poi.db" \
   /usr/local/share/data/osm/feature_city_poi.db

# fool the hardcoded bastard
mkdir -p /usr/share/mapnik/world_boundaries

# bypass Mapnik wanting 300mb World Boundaries DB to be installed, use Natural Earth instead.
sed -e 's+/usr/share/mapnik/world_boundaries/world_boundaries_m+/usr/local/share/data/natural_earth2/ne_10m_land+' \
    -e 's/Layer name="world-1".*/Layer name="world-1" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/world_bnd_m+/usr/local/share/data/natural_earth2/ne_10m_land+' \
    -e 's/Layer name="world".*/Layer name="world" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/processed_p+/usr/local/share/data/natural_earth2/ne_10m_land+' \
    -e 's/Layer name="coast-poly".*/Layer name="coast-poly" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/builtup_area+/usr/local/share/data/natural_earth2/ne_10m_urban_areas+' \
    -e 's/Layer name="buildup".*/Layer name="builtup" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/places+/usr/local/share/data/natural_earth2/ne_10m_populated_places+' \
    -e 's/Layer name="places".*/Layer name="builtup" status="on" srs="+proj=longlat +datum=WGS84 +no_defs">/' \
    \
    /usr/share/gpsdrive/osm-template.xml > "/etc/skel/.gpsdrive/osm.xml"
# "$TMP_DIR/gpsdrive-$VERSION/build/scripts/mapnik/osm-template.xml" \


# change DB name from "gis" to "osm_local" as per load_postgis.sh
sed -i -e 's+<Parameter name="dbname">gis</Parameter>+<Parameter name="dbname">osm_local</Parameter>+' \
  "/etc/skel/.gpsdrive/osm.xml"

# and change from epsg:900913 to epsg:4326 to match the "osm_local" DB's SRS
sed -i -e 's|\("on" srs="\)+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs|\1+proj=longlat +datum=WGS84|' \
  "/etc/skel/.gpsdrive/osm.xml"

# layer extent too:  (FIXME, just guessed from the larger BBOX in install_osm.sh)
sed -i -e 's|-20037508,-19929239,20037508,19929239|-122.8,45.4,-122.5,45.6|' \
  "/etc/skel/.gpsdrive/osm.xml"

# avoid shapefile column city name mismatch & tweak its map scale render rule:
sed -i -e 's|TextSymbolizer name="\[place_name\]"|TextSymbolizer name="[NAME]"|' \
       -e 's|<MaxScaleDenominator>10000000</|<MaxScaleDenominator>500000</|' \
       -e 's|<MinScaleDenominator>10000000</|<MinScaleDenominator>1000000</|' \
  "/etc/skel/.gpsdrive/osm.xml"


# osm.xml changes for Mapnik2 ...
sed -i -e 's/ face_name=/ face-name=/' \
       -e 's/TextSymbolizer name="\([^"]*\)"/TextSymbolizer name="[\1]"/' \
       -e 's/ShieldSymbolizer name="\([^"]*\)"/ShieldSymbolizer name="[\1]"/' \
       -e 's/Map bgcolor=/Map background-color=/' \
       -e 's|CssParameter name="\([^"]*\)">|Css>\1="|' \
       -e 's|</CssParameter|"</Css|' \
       -e 's|halo_fill|halo-fill|' \
       -e 's|halo_radius|halo-radius|' \
       -e 's|allow_overlap|allow-overlap|' \
       -e 's|wrap_width|wrap-width|' \
       -e 's|min_distance|minimum-distance|' \
       -e 's|\.png" type="png" width="[^"]*" height="[^"]*"|.png" |' \
  "/etc/skel/.gpsdrive/osm.xml"

# todo: combine into a single command:
perl -0777 -i.original -pe 's/Symbolizer>\n        <Css>/Symbolizer /g' \
    "/etc/skel/.gpsdrive/osm.xml"
perl -0777 -i.original -pe 's/<\/Css>\n        <Css>/ /g' \
    "/etc/skel/.gpsdrive/osm.xml"
perl -0777 -i.original -pe 's/<\/Css>\n      <\/LineSymbolizer>/ \/>/g' \
    "/etc/skel/.gpsdrive/osm.xml"
perl -0777 -i.original -pe 's/<\/Css>\n      <\/PolygonSymbolizer>/ \/>/g' \
    "/etc/skel/.gpsdrive/osm.xml"


# use (new) official debian pkg home of map icons
sed -i -e 's/map-icons/openstreetmap/' \
       -e 's|classic.small/rendering/landuse/forest.png|classic.big/rendering/landuse/forest.png|' \
  "/etc/skel/.gpsdrive/osm.xml"

cp /etc/skel/.gpsdrive/osm.xml "$USER_HOME/.gpsdrive/"


chown -R $USER_NAME:$USER_NAME "$USER_HOME/.gpsdrive"

cp /usr/share/applications/gpsdrive.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/gpsdrive.desktop"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

exit





############################################################################
############################################################################
############################################################################

############################################################################


############################################################################




############################################################################
