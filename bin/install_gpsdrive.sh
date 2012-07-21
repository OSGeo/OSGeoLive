#!/bin/sh
# Copyright (c) 2009 by Hamish Bowman, and the Open Source Geospatial Foundation
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
# script to install GpsDrive
#    written by H.Bowman <hamish_b  yahoo com>
#    GpsDrive homepage: http://www.gpsdrive.de
#


CITY=Nottingham

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_gpsdrive
BUILD_DIR=`pwd`


#### install program ####

PACKAGES="gpsd gpsd-clients python-gps \
   espeak gdal-bin gpsbabel \
   graphicsmagick-imagemagick-compat \
   postgresql-9.1-postgis \
   python-mapnik2 \
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

URL="http://download.osgeo.org/livedvd/data/gpsdrive/precise/i386"
MAIN_FILE="gpsdrive_2.12+svn2685-1_i386.deb"
EXTRA_FILES="
  gpsdrive-friendsd_2.12+svn2685-1_i386.deb
  gpsdrive-utils_2.12+svn2685-1_i386.deb"

wget -c --progress=dot:mega "$URL/$MAIN_FILE"
for FILE in $EXTRA_FILES ; do
   wget -c -nv "$URL/$FILE"
done

gdebi --non-interactive --quiet gpsdrive-friendsd_2.12+svn2685-1_i386.deb
gdebi --non-interactive --quiet gpsdrive-utils_2.12+svn2685-1_i386.deb
gdebi --non-interactive --quiet gpsdrive_2.12+svn2685-1_i386.deb



#### install data ####

mkdir "$USER_HOME/.gpsdrive"


# program defaults
cat << EOF > "$USER_HOME/.gpsdrive/gpsdriverc"
lastlong = 116.405
lastlat = 39.98
scalewanted = 50000
dashboard_3 = 12
autobestmap = 0
mapnik = 1
mapnik_caching = 0
minsecmode = 2
friendsname = LiveDVD
showbutton_trackrestart = 0
showbutton_trackclear = 0
icon_theme = classic.small
osmdbfile = /usr/local/share/data/osm/${CITY}_poi.db
mapnik_postgis_dbname = osm_local_smerc
EOF


# add any waypoints you want to see displayed
cat << EOF > "$USER_HOME/.gpsdrive/way.txt"
Sydney_Convention_Centre        -33.8750   151.2005
Barcelona_Convention_Centre      41.3724     2.1518
FOSS4G_2011_(Sheraton_Denver)    39.74251 -104.9891
OSM_State_of_the_Map_2011        39.7457  -105.0034
Business_School_South_(Jubilee)  52.9517  -1.1864
East_Midlands_Conference_Centre  52.9387  -1.2034
EOF


#download latest OSM POIs for host city
#wget -N --progress=dot:mega  http://poi.gpsdrive.de/$COUNTRY.db.bz2
wget -N --progress=dot:mega \
  "http://download.osgeo.org/livedvd/data/osm/$CITY/${CITY}_poi.db.bz2"
bzip2 -d "${CITY}_poi.db.bz2"
mkdir -p /usr/local/share/osm/
mkdir -p /usr/local/share/data/osm/
mv "${CITY}_poi.db" /usr/local/share/osm/
ln -s /usr/local/share/osm/"${CITY}_poi.db" /usr/local/share/data/osm/feature_city_poi.db

# fool the hardcoded bastard
mkdir -p /usr/share/mapnik/world_boundaries

# bypass Mapnik wanting 300mb World Boundaries DB to be installed, use Natural Earth instead.
sed -e 's+/usr/share/mapnik/world_boundaries/world_boundaries_m+/usr/local/share/data/natural_earth/10m_land+' \
    -e 's/Layer name="world-1".*/Layer name="world-1" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/world_bnd_m+/usr/local/share/data/natural_earth/10m_land+' \
    -e 's/Layer name="world".*/Layer name="world" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/processed_p+/usr/local/share/data/natural_earth/10m_land+' \
    -e 's/Layer name="coast-poly".*/Layer name="coast-poly" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/builtup_area+/usr/local/share/data/natural_earth/10m_urban_areas+' \
    -e 's/Layer name="buildup".*/Layer name="builtup" status="on" srs="+proj=longlat +datum=WGS84 +no_defs +over">/' \
    \
    -e 's+/usr/share/mapnik/world_boundaries/places+/usr/local/share/data/natural_earth/10m_populated_places_simple+' \
    -e 's/Layer name="places".*/Layer name="builtup" status="on" srs="+proj=longlat +datum=WGS84 +no_defs">/' \
    \
    /usr/share/gpsdrive/osm-template.xml > "$USER_HOME/.gpsdrive/osm.xml"
# "$TMP_DIR/gpsdrive-$VERSION/build/scripts/mapnik/osm-template.xml" \


# change DB name from "gis" to "osm_local_smerc" as per install_osm.sh
sed -i -e 's+<Parameter name="dbname">gis</Parameter>+<Parameter name="dbname">osm_local_smerc</Parameter>+' \
  "$USER_HOME/.gpsdrive/osm.xml"

# avoid shapefile column city name mismatch & tweak its map scale render rule:
sed -i -e 's|\[place_name\]</TextSymbolizer>|[NAME]</TextSymbolizer>|' \
       -e 's|<MaxScaleDenominator>10000000</|<MaxScaleDenominator>500000</|' \
  "$USER_HOME/.gpsdrive/osm.xml"



chown -R $USER_NAME:$USER_NAME "$USER_HOME/.gpsdrive"

cp /usr/share/applications/gpsdrive.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/gpsdrive.desktop"


echo "Finished installing GpsDrive."

exit





############################################################################
############################################################################
############################################################################

############################################################################


############################################################################




############################################################################


if [ 1 -eq 0 ] ; then
  ## needed for newer builds if icons were *not* installed via .debs above
  # minimal icon set
  wget -c -nv "http://downloads.sourceforge.net/project/gpsdrive/additional%20data/minimal%20icon%20set/openstreetmap-map-icons-minimal.tar.gz?use_mirror=internode"
  cd /
  tar xzf "$TMP_DIR"/openstreetmap-map-icons-minimal.tar.gz
  cd "$TMP_DIR"

  #debug dummy copy of geoinfo.db
  #tar xzf openstreetmap-map-icons-minimal.tar.gz usr/share/icons/map-icons/geoinfo.db
  #cp usr/share/icons/map-icons/geoinfo.db "$USER_HOME/.gpsdrive/"
  #  .gpsdrive/gpsdriverc: geoinfofile = $USER_HOME/.gpsdrive/geoinfo.db
fi



## packaged version (2.10pre4) is long out of date, so we build 2.11svn manually.
BUILD_LATEST=0


#######################
## build latest release
if [ $BUILD_LATEST -eq 1 ] ; then
  VERSION="2.12svn"

  if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
  fi
  cd "$TMP_DIR"

  ## FIXME (use better home once known/officially released)
  ##  wget -c --progress=dot:mega "http://www.gpsdrive.de/packages/gpsdrive-$VERSION.tar.gz"
  FILE=gpsdrive_2.12svn2645.tar.gz
  wget --progress=dot:mega -O "$FILE" \
     "http://sites.google.com/site/hamishbowman/${FILE}?attredirects=0"

  #tar xzf gpsdrive-$VERSION.tar.gz
  #if [ $? -eq 0 ] ; then
  #  \rm gpsdrive-$VERSION.tar.gz
  #fi

  #cd gpsdrive-$VERSION

  # FIXME
  mkdir gpsdrive-2.12svn
  cd gpsdrive-2.12svn
  tar xzf "../$FILE"


  ## --- apply any patches here ---

  # fix package dependencies
  PATCH="gpsdrive_blue_mapnik"
  patch -p0 < "$BUILD_DIR/../app-conf/gpsdrive/$PATCH.patch"

  if [ $? -ne 0 ] ; then
     echo "An error occurred patching package. Aborting install."
     exit 1
  fi


  ### install any missing build-dep packages

  # kludge to make sure these make it in there
  apt-get --assume-yes install libboost1.46-dev libboost-filesystem1.46-dev \
                               libboost-serialization1.46-dev libmapnik-dev

  # explicitly install these so they aren't removed in a later autoclean
  apt-get --assume-yes install  libgeos-3.2.2 libxml-simple-perl \
    libboost-serialization1.46.0 libboost-date-time1.46.0

  # any of these too?
  #  libgssrpc4
  #  libodbcinstq1c2
  #  libpcrecpp0
  #  libpthread-stubs0
  #  libtiffxx0c2
  #  libkdb5-4 


  NEEDED_BUILD_PKG=`dpkg-checkbuilddeps 2>&1 |  grep -v 'is deprecated: use' | \
    cut -f3 -d: | sed -e 's/([^)]*)//g' -e 's/| [^ ]*//g' -e 's/|//g'`

  if [ -n "$NEEDED_BUILD_PKG" ] ; then
     echo "Attempting to (temporarily) install the following packages: $NEEDED_BUILD_PKG"
     apt-get --assume-yes install $NEEDED_BUILD_PKG

     # don't exit on fail because pbuilder will try next
  else
     echo "No new packages needed for build."
  fi

  # ... and if that didn't work, try another way ...

  # dpkg-dev and pbuilder are installed by setup.sh, but somewhere got removed?!
  apt-get --assume-yes install dpkg-dev pbuilder

  /usr/lib/pbuilder/pbuilder-satisfydepends

  #fix + use system copy
  rm -f cmake/Modules/FindGTK2.cmake
  sed -i -e 's+/usr/local/lib64+/usr/lib/i386-linux-gnu+' \
       /usr/share/cmake-2.8/Modules/FindGTK2.cmake

#  #fix unneeded package (?scripts/osm/perl_lib/Geo/Gpsdrive/getstreet.pm 
#  #   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=580588 )
#  sed -i -e 's+^\t libtext-query-perl+#\t libtext-query-perl+' debian/control


  # build package
  # - debuild and co. should already be installed by setup.sh
  #debuild binary
  debuild -i -uc -us -b
  if [ $? -ne 0 ] ; then
     echo "An error occurred building package. Aborting install."
     exit 1
  fi


  #### install our new custom built packages ####
  cd "$TMP_DIR"
 
  # get+install at least one OSM icon set package
  #   see http://www.gpsdrive.de/development/map-icons/overview.en.shtml

  #echo "Downloading support packages ... (please wait)"
  #DL_URL="http://www.gpsdrive.de/ubuntu/pool/precise"
  # holy cow, mapnik-world-boundaries.deb is 300mb!
  #wget -c "$DL_URL/openstreetmap-mapnik-world-boundaries_17758_all.deb"

  dpkg -i openstreetmap-map*.deb

  CUSTOM_PKGS="gpsdrive*.deb"

  # install package dependencies
  #### TODO: replace all this mess with "gdebi"
  echo "Checking if local.deb needs are already installed ..."
  EXTRA_PKGS="osm2pgsql"
  for PKG in $CUSTOM_PKGS ; do
     if [ `echo $PKG | cut -f1 -d_` = "openstreetmap-map-icons" ] ; then
        # skip overenthusiastic recommends
        continue
     fi
     REQ_PKG=`dpkg --info "$PKG" | grep '^ Depends: ' | \
       cut -f2- -d: | tr ',' '\n' | cut -f1 -d'|' | \
       sed -e 's/^ //' -e 's/(.*$//' | tr '\n' ' '`
     echo "$PKG wants: $REQ_PKG"
     EXTRA_PKGS="$EXTRA_PKGS $REQ_PKG"
  done


  EXTRA_PKGS=`echo $EXTRA_PKGS | tr ' ' '\n' | sort -u | \
     grep -v 'gpsdrive\|openstreetmap-map-icons'`

  TO_INSTALL=""
  for PACKAGE in $EXTRA_PKGS ; do
     if [ `dpkg -l "$PACKAGE" | grep -c '^ii'` -eq 0 ] ; then
        TO_INSTALL="$TO_INSTALL $PACKAGE"
     fi
  done

  # remove libltdl swap as it's now redundant after testing new dep patch
#?  TO_INSTALL=`echo "$TO_INSTALL" | sed -e 's/|//g' -e 's/libltdl3/libltdl7/'`


  if [ -n "$TO_INSTALL" ] ; then
     echo "Attempting to install the following packages: $TO_INSTALL"

     apt-get install --yes $TO_INSTALL

     if [ $? -ne 0 ] ; then
        echo "ERROR: packages install failed: $TO_INSTALL"
        exit 1
     fi
  else
     echo "No new packages needed for install."
  fi


  dpkg -i gpsdrive*.deb \
          openstreetmap-map*.deb


  # cleanup
   # from kludge to make sure these made it in there
  apt-get --assume-yes remove libboost-dev libmapnik-dev \
     libboost-filesystem-dev libboost-serialization-dev \
     pbuilder-satisfydepends-dummy

   # from auto-detect
  if [ -n "$NEEDED_BUILD_PKG" ] ; then
     apt-get --assume-yes remove $NEEDED_BUILD_PKG
  fi
  # don't worry (too much) if the above fails, it's just removing cruft.
  # we really want a --assume-no switch to only remove if perfectly safe

  #cleanup, need to assume otherwise it prompts
  apt-get --assume-yes autoremove

fi
##
## end self-build
#######################
