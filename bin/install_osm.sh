#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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

USER_NAME=user
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_osm


if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
BUILD_DIR=`pwd`
cd "$TMP_DIR"

mkdir /usr/local/share/osm


apt-get install --assume-yes josm josm-plugins gosmore gpsd gpsd-clients \
   merkaartor xmlstarlet



### TODO: install osmosis as well.


# that JOSM is badly out of date, so get the latest:
#   leave it installed to keep dependencies
#   file name is not versioned so don't use "wget -c"
wget --progress=dot:mega -O /usr/local/share/osm/josm-tested.jar \
   http://josm.openstreetmap.de/josm-tested.jar
# replace symlink
rm /usr/share/josm/josm.jar
ln -s /usr/local/share/osm/josm-tested.jar /usr/share/josm/josm.jar

# pre-seed the josmrc file to make the default window size fit on a smaller display
mkdir -p "$USER_HOME"/.josm
cat << EOF > "$USER_HOME"/.josm/preferences
gui.geometry=800x600+40+40
gui.maximized=false
EOF
chown $USER_NAME.$USER_NAME "$USER_HOME"/.josm -R


#### a handy python utility
svn co http://svn.openstreetmap.org/applications/utils/python_lib/OsmApi .
cp OsmApi.py /usr/lib/python2.7/

#### desktop icons
echo '#!/usr/bin/env xdg-open' > "$USER_HOME"/Desktop/josm.desktop
cat /usr/share/applications/josm.desktop >> "$USER_HOME"/Desktop/josm.desktop
chmod a+x "$USER_HOME"/Desktop/josm.desktop

## need to make one for gosmore
cat << EOF > /usr/share/applications/gosmore.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Name=Gosmore
Comment=Viewer for OpenStreetMap.com
Exec=/usr/local/bin/launch_gosmore.sh
Icon=josm-32
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;
EOF

chmod a+x /usr/share/applications/gosmore.desktop
cp /usr/share/applications/gosmore.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/merkaartor.desktop "$USER_HOME/Desktop/"


cp "$BUILD_DIR/../app-conf/osm/launch_gosmore.sh" /usr/local/bin/


if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

mkdir -p /usr/local/share/osm



# install osmrender - it's a renderer from .osm to svg
#   http://wiki.openstreetmap.org/wiki/Osmarender
# two implementations to choose from, one in perl, one using **> xslt <**
# download:  http://svn.openstreetmap.org/applications/rendering/osmarender
#  (both implementations and the stylesheets and other stuff is in that svn co)
# view SVG with Firefox or Inkscape
# run with:  osmarender <filename.osm>

BASEURL="http://svn.openstreetmap.org/applications/rendering/osmarender"
FILES="stylesheets/osm-map-features-z17.xml stylesheets/markers.xml xslt/osmarender.xsl xslt/osmarender xslt/xsltrans"
for FILE in $FILES ; do
  wget -nv "$BASEURL/$FILE"
done

chmod a+x osmarender xsltrans
sed -i -e 's|OSMARENDER="."|OSMARENDER="/usr/local/share/osm"|' osmarender
cp osmarender /usr/local/bin/

mkdir -p /usr/local/share/osm/xslt
cp xsltrans osmarender.xsl /usr/local/share/osm/xslt/
mkdir -p /usr/local/share/osm/stylesheets
cp osm-map-features-z17.xml markers.xml /usr/local/share/osm/stylesheets/

svn co "$BASEURL/stylesheets/symbols/" /usr/local/share/osm/stylesheets/symbols/



#### install sample OSM data

CITY="Beijing"
BBOX="116.25,39.85,116.5,40"
# visualize:
#http://www.openstreetmap.org/?box=yes&bbox=116.25,39.85,116.5,40


# Perhaps it is too big a city for some of our examples, so we download
# a smaller version too:
#CITY="Denver_CBD"
#BBOX="-105.028,39.709,-104.956,39.79"

# City OSM data:
#  Having a sample .osm file around will benefit many applications. In addition
#  to JOSM and Gosmore, QGIS and Mapnik can also render .osm directly.
#
# We should also push the .osm file into postgis/postgres with osm2pgsql.
#
# $ createdb -T template_postgis osm_$CITY
# $ osm2pgsql -d osm_$CITY $CITY.osm
# 

### Please update to latest data at the last minute! See data dir on server for details.
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/osm/$CITY.osm.bz2"


#download as part of disc build process
# Downloading from the osmxapi takes me about 6 minutes and is around 20MB.
# hypercube is near the OSGeo servers at SDSC so should be much faster.

# Xapi is dying,
#   http://thread.gmane.org/gmane.comp.gis.openstreetmap/56097/
# long live Xapi,
#   https://github.com/iandees/xapi-servlet
# for our simple "planet extract" needs, maybe OSM3S would be a better fit anyway?
#   http://wiki.openstreetmap.org/wiki/OSM3S/install
#   http://78.46.81.38/#section.download_area

if [ ! -e "$CITY.osm.bz2" ] ; then
  #XAPI_URL="http://xapi.openstreetmap.org/api/0.6"
  #XAPI_URL="http://open.mapquestapi.com/xapi/api/0.6"
  XAPI_URL="http://jxapi.openstreetmap.org/xapi/api/0.6"

  wget --progress=dot:mega -O "$CITY.osm"  "$XAPI_URL/*[bbox=$BBOX]"
  if [ $? -ne 0 ] ; then
     echo "ERROR getting osm data"
     exit 1
  fi
  bzip2 "$CITY.osm"
fi


cp -f "$CITY.osm.bz2" /usr/local/share/osm/
mkdir -p /usr/local/share/data/osm --verbose
ln -s /usr/local/share/osm/"$CITY.osm.bz2" /usr/local/share/data/osm
ln -s /usr/local/share/data/osm/"$CITY.osm.bz2" \
   /usr/local/share/data/osm/feature_city.osm.bz2

####
wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/osm/Denver_CBD.osm.bz2"
cp -f "Denver_CBD.osm.bz2" /usr/local/share/osm/
ln -s /usr/local/share/osm/Denver_CBD.osm.bz2 /usr/local/share/data/osm
####



apt-get --assume-yes install osm2pgsql


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



