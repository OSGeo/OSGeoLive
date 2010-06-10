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


apt-get install --assume-yes josm josm-plugins gosmore gpsd gpsd-clients merkaartor xmlstarlet


# that JOSM is badly out of date, so get the latest:
#   leave it installed to keep dependencies
#   file name is not versioned so don't use "wget -c"
wget --progress=dot:mega -O /usr/local/share/osm/josm-tested.jar \
   http://josm.openstreetmap.de/josm-tested.jar
# replace symlink
rm /usr/share/josm/josm.jar
ln -s /usr/local/share/osm/josm-tested.jar /usr/share/josm/josm.jar


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
Exec=/usr/bin/gosmore
Icon=josm-32
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;
EOF

chmod a+x /usr/share/applications/gosmore.desktop
cp /usr/share/applications/gosmore.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/merkaartor.desktop "$USER_HOME/Desktop/"


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

# Auckland:
cp "$BUILD_DIR"/../app-data/osm/Auckland.osm.gz /usr/local/share/osm/


# Barcelona data:
#  Having a sample .osm file around will benefit many applications. In addition
#  to JOSM and Gosmore, QGIS and Mapnik can also render .osm directly.
#  grab Barcelona, which can be as easy as:
#
# $ wget -O barcelona.osm http://osmxapi.hypercube.telascience.org/api/0.6/map?bbox=1.998653,41.307213,2.343693,41.495207
#
# We should also push the .osm file into postgis/postgres with osm2pgsql.
#
# $ createdb -T template_postgis osm_barcelona
# $ osm2pgsql -d osm_barcelona barcelona.osm
# 

### Please update to latest data at the last minute! See data dir on server for details.
#wget --progress=dot:mega "http://download.osgeo.org/livedvd/data/osm/Barcelona.osm.bz2"

#download as part of disc build process
# Downloading from the osmxapi takes me about 6 minutes and is around 20MB.
# hypercube is near the OSGeo servers at SDSC so should be much faster.

if [ ! -e 'Barcelona.osm.bz2' ] ; then
  XAPI_URL="http://osmxapi.hypercube.telascience.org/api/0.6"
  BBOX="1.998653,41.307213,2.343693,41.495207"

  wget --progress=dot:mega -O Barcelona.osm  "$XAPI_URL/map?bbox=$BBOX"
  if [ $? -ne 0 ] ; then
     echo "ERROR getting osm data"
     exit 1
  fi
  bzip2 Barcelona.osm
fi
cp -f Barcelona.osm.bz2 /usr/local/share/osm/

