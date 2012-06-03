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




echo "The GpsDrive package is not yet ready for Ubuntu 12.04"
exit 0


CITY=Beijing


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_gpsdrive
BUILD_DIR=`pwd`


#### install program ####

## packaged version (2.10pre4) is long out of date, so we build 2.11svn manually.
BUILD_LATEST=0

# base packages
if [ "$BUILD_LATEST" -eq 0 ] ; then
   # install very old pre-packaged version
   #PACKAGES="gpsd gpsd-clients python-gps gpsdrive"
   PACKAGES="gpsd gpsd-clients python-gps"
else
   # important pre-req
   PACKAGES="gpsd gpsd-clients python-gps"
fi

# add some useful Recommends
PACKAGES="$PACKAGES espeak gdal-bin gpsbabel \
   graphicsmagick-imagemagick-compat \
   postgresql-9.1-postgis python-mapnik2 \
   speech-dispatcher"

apt-get --assume-yes install  $PACKAGES

if [ $? -ne 0 ] ; then
   echo "An error occurred installing packages. Aborting install."
   exit 1
fi

# highly useful
apt-get --assume-yes install sqlite3 sqlitebrowser



#######################
## use prebuilt debs

if [ $BUILD_LATEST -eq 0 ] ; then
  if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
  fi
  cd "$TMP_DIR"

  URL="http://download.osgeo.org/livedvd/data/gpsdrive/precise"
  MAIN_FILE=gpsdrive_2.11_i386.deb
  EXTRA_FILES="
    gpsdrive-friendsd_2.11_i386.deb
    gpsdrive-utils_2.11_i386.deb
    openstreetmap-map-icons-classic.small_25996_all.deb
    openstreetmap-map-icons-square.big_25996_all.deb
    openstreetmap-map-icons-square.small_25996_all.deb
    openstreetmap-map-icons_25996_all.deb"

  wget -c --progress=dot:mega "$URL/$MAIN_FILE"
  for FILE in $EXTRA_FILES ; do
     wget -c -nv "$URL/$FILE"
  done

  dpkg -i openstreetmap-map-icons*.deb
  gdebi --non-interactive --quiet gpsdrive-friendsd_2.11_i386.deb
  gdebi --non-interactive --quiet gpsdrive-utils_2.11_i386.deb
  gdebi --non-interactive --quiet gpsdrive_2.11_i386.deb

fi



#######################
## build latest release
if [ $BUILD_LATEST -eq 1 ] ; then
  VERSION="2.11svn"

  if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
  fi
  cd "$TMP_DIR"

  ## FIXME (use better home once known/officially released)
  ##  wget -c --progress=dot:mega "http://www.gpsdrive.de/packages/gpsdrive-$VERSION.tar.gz"
  FILE=gpsdrive_2.11svn2556.tar.gz
  wget --progress=dot:mega -O "$FILE" \
     "http://sites.google.com/site/hamishbowman/${FILE}?attredirects=0"

  #tar xzf gpsdrive-$VERSION.tar.gz
  #if [ $? -eq 0 ] ; then
  #  \rm gpsdrive-$VERSION.tar.gz
  #fi

  #cd gpsdrive-$VERSION

  # FIXME
  mkdir gpsdrive-2.11svn
  cd gpsdrive-2.11svn
  tar xzf "../$FILE"


  ## --- apply any patches here ---

  # fix package dependencies
  PATCHES="gpsdrive_blue_mapnik"

  for PATCH in $PATCHES ; do
     patch -p0 < "$BUILD_DIR/../app-conf/gpsdrive/$PATCH.patch"
  done

  if [ $? -ne 0 ] ; then
     echo "An error occurred patching package. Aborting install."
     exit 1
  fi

  # local database name is "osm_local_smerc"
  sed -i -e 's/"gis"/"osm_local_smerc"/' src/database.c

  # installed mapnik version is 2.0
  MAPNIK_VER=2.0
  sed -i -e "s+/usr/lib/mapnik/0.5+/usr/lib/mapnik/$MAPNIK_VER+" src/gpsdrive_config.c
  sed -i -e 's+^      mapnik$+      mapnik2+' cmake/Modules/FindMapnik.cmake


# no longer needed? better to use `sed -i` for this anyway..
if [ 0 -eq 1 ] ; then
  cat << EOF > "gpsdrive_fix_icon.patch"
--- data/gpsdrive.desktop.ORIG  2009-08-31 01:42:39.000000000 +1200
+++ data/gpsdrive.desktop       2009-08-31 01:43:19.000000000 +1200
@@ -3,7 +3,7 @@
 Comment=GPS Navigation. You need to setup Gpsd manually
 Comment[de]=GPS Navigationsprogramm
 Exec=gpsdrive
-Icon=gpsicon
+Icon=/usr/share/gpsdrive/pixmaps/gpsicon.png
 Terminal=false
 Type=Application
 Categories=Graphics;Network;Geography;
EOF
   patch -p0 < "gpsdrive_fix_icon.patch"
fi


  #apply debian/ubuntu-lucid-32 patches to sync package deps for Lucid
  sed -i -e 's/Build with old libgps version (<2.90)" ON)/Build with old libgps version (<2.90)" OFF)/' \
      DefineOptions.cmake


  if [ $? -ne 0 ] ; then
     echo "An error occurred patching package. Aborting install."
     exit 1
  fi


  # use latest libboost, mapnik, postgis packages
  BOOST_VER=1.46.0
  PGIS_VER=9.1
  sed -i -e "s/libboost-\(.*\)1\.3[0-9]\.[0-9]/libboost-\1$BOOST_VER/" \
         -e 's/mapnik0\.[3-6]/mapnik2-2.0/' \
	 -e 's/libmapnik-dev/libmapnik2-dev/' \
         -e "s/postgresql-8\.[2-3]-postgis/postgresql-$PGIS_VER-postgis/" \
     debian/control

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

  #fix unneeded package (?scripts/osm/perl_lib/Geo/Gpsdrive/getstreet.pm 
  #   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=580588 )
  sed -i -e 's+^\t libtext-query-perl+#\t libtext-query-perl+' debian/control

  
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

  # see what happens if we install the offical icon packages
  apt-get  --assume-yes install openstreetmap-map-icons-square \
     openstreetmap-map-icons-scalable openstreetmap-map-icons-classic

  echo "Downloading support packages ... (please wait)"
  DL_URL="http://www.gpsdrive.de/ubuntu/pool/precise"

  # dupe?
  wget -c -nv "$DL_URL/openstreetmap-map-icons-square.small_25996_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons-square.big_25996_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons-classic.small_25996_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons_25996_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons_25996_all.deb"

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




#### install data ####
mkdir "$USER_HOME/.gpsdrive"


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


# program defaults
cat << EOF > "$USER_HOME/.gpsdrive/gpsdriverc"
lastlong = -104.9895
lastlat = 39.7424
scalewanted = 3000
dashboard_3 = 12
autobestmap = 0
mapnik = 1
mapnik_caching = 0
minsecmode = 2
friendsname = LiveDVD
showbutton_trackrestart = 0
showbutton_trackclear = 0
icon_theme = classic.small
osmdbfile = /usr/share/gpsdrive/${CITY}_poi.db
EOF


# add any waypoints you want to see displayed
cat << EOF > "$USER_HOME/.gpsdrive/way.txt"
Sydney_Convention_Centre        -33.8750  151.2005
Barcelona_Convention_Centre      41.3724    2.1518
FOSS4G_2011_(Sheraton_Denver)    39.74251 -104.9891
OSM_State_of_the_Map_2011        39.7457  -105.0034
Beijing                          40.0      116.5
EOF

#download latest OSM POIs for host city
#wget -N --progress=dot:mega  http://poi.gpsdrive.de/$COUNTRY.db.bz2
wget -N --progress=dot:mega \
  http://download.osgeo.org/livedvd/data/osm/${CITY}_poi.db.bz2
bzip2 -d "${CITY}_poi.db.bz2"
mv "${CITY}_poi.db" /usr/share/gpsdrive/


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

# ensure fonts are loaded for Mapnik
apt-get --assume-yes install ttf-dejavu-extra


chown -R $USER_NAME:$USER_NAME "$USER_HOME/.gpsdrive"

cp /usr/share/applications/gpsdrive.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/gpsdrive.desktop"


echo "Finished installing GpsDrive."
