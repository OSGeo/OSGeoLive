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


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_gpsdrive
BUILD_DIR=`pwd`


#### install program ####

## packaged version (2.10pre4) is long out of date, so we build 2.10pre7 manually.
BUILD_LATEST=1

# base packages
if [ "$BUILD_LATEST" -eq 0 ] ; then
   # install very old pre-packaged version
   PACKAGES="gpsd gpsd-clients python-gps gpsdrive"
else
   # important pre-req
   PACKAGES="gpsd gpsd-clients python-gps"
fi

# add some useful Recommends
PACKAGES="$PACKAGES espeak gdal-bin gpsbabel graphicsmagick-imagemagick-compat \
   postgresql-8.4-postgis python-mapnik speech-dispatcher"

apt-get --assume-yes install  $PACKAGES

if [ $? -ne 0 ] ; then
   echo "An error occurred installing packages. Aborting install."
   exit 1
fi

# highly useful
apt-get --assume-yes install sqlite3 sqlitebrowser


#######################
## build latest release
if [ $BUILD_LATEST -eq 1 ] ; then
  VERSION="2.10pre7"

  if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
  fi
  cd "$TMP_DIR"

  wget -c --progress=dot:mega "http://www.gpsdrive.de/packages/gpsdrive-$VERSION.tar.gz"

  tar xzf gpsdrive-$VERSION.tar.gz
  #if [ $? -eq 0 ] ; then
  #  \rm gpsdrive-$VERSION.tar.gz
  #fi

  cd gpsdrive-$VERSION


  ## --- apply any patches here ---

  # fix package dependencies
  PATCHES="gpsdrive_fix_deps  gpsdrive_osm_fixes  gpsdrive_blue_mapnik"

  for PATCH in $PATCHES ; do
     patch -p0 < "$BUILD_DIR/../app-data/gpsdrive/$PATCH.patch"
  done

  if [ $? -ne 0 ] ; then
     echo "An error occurred patching package. Aborting install."
     exit 1
  fi

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


  if [ $? -ne 0 ] ; then
     echo "An error occurred patching package. Aborting install."
     exit 1
  fi


  ### install any missing build-dep packages

  # kludge to make sure these make it in there
  apt-get --assume-yes install libboost-dev libboost-filesystem-dev libboost-serialization-dev
  apt-get --assume-yes install libmapnik-dev

  # explicitly install these so they aren't removed in a later autoclean
  apt-get --assume-yes install  libgeos-3.1.1 \
    libboost-serialization1.38.0 libboost-date-time1.38.0
  # any of these too?
  #  libgssrpc4
  #  libodbcinstq1c2
  #  libpcrecpp0
  #  libpthread-stubs0
  #  libtiffxx0c2
  #  libkdb5-4 


  NEEDED_BUILD_PKG=`dpkg-checkbuilddeps 2>&1 | cut -f3 -d: | \
    sed -e 's/([^)]*)//g' -e 's/| [^ ]*//g' -e 's/|//g'`

  if [ -n "$NEEDED_BUILD_PKG" ] ; then
     echo "Attempting to (temporarily) install the following packages: $NEEDED_BUILD_PKG"
     apt-get --assume-yes install $NEEDED_BUILD_PKG

     # don't exit on fail because pbuilder will try next
  else
     echo "No new packages needed for build."
  fi

  # ... and if that didn't work, try another way ...
  /usr/lib/pbuilder/pbuilder-satisfydepends


  # build package
  # - debuild and co. should already be installed by setup.sh
  debuild binary
  if [ $? -ne 0 ] ; then
     echo "An error occurred building package. Aborting install."
     exit 1
  fi


  #### install our new custom built packages ####
  cd "$TMP_DIR"
 
  # get+install at least one OSM icon set package
  #   see http://www.gpsdrive.de/development/map-icons/overview.en.shtml
  echo "Downloading support packages ... (please wait)"
  DL_URL="http://www.gpsdrive.de/debian/pool/squeeze"

  wget -c -nv "$DL_URL/openstreetmap-map-icons-square.small_16908_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons-square.big_16908_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons-classic.small_16908_all.deb"
  wget -c -nv "$DL_URL/openstreetmap-map-icons_16908_all.deb"

  # holy cow, mapnik-world-boundaries.deb is 300mb!
  #wget -c "$DL_URL/openstreetmap-mapnik-world-boundaries_16662_all.deb"


  CUSTOM_PKGS="gpsdrive*.deb openstreetmap-map*.deb"

  # install package dependencies
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
  TO_INSTALL=`echo "$TO_INSTALL" | sed -e 's/|//g' -e 's/libltdl3/libltdl7/'`

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
fi
##
## end self-build
#######################

#cleanup, need to assume otherwise it prompts
apt-get --assume-yes autoremove


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
lastlong = 151.2001
lastlat = -33.8753
scalewanted = 5000
dashboard_3 = 12
autobestmap = 0
mapnik_caching = 0
minsecmode = 2
friendsname = LiveDVD
EOF


# add any waypoints you want to see displayed
echo "Convention_Centre   -33.8750   151.2005" > "$USER_HOME/.gpsdrive/way.txt"


# Sydney maps
#  v0.1, 1.1mb LANDSAT tiles
#wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/gpsdrive/gpsdrive_syd_tileset-0.1.tar.gz"

#  v1.1, 70mb LANDSAT + OpenStreetMap tiles
# move to .au mirror once it becomes avail.
wget -c --progress=dot:mega "http://downloads.sourceforge.net/project/gpsdrive/additional%20data/gpsdrive_syd_tileset-1.1.tar.gz?use_mirror=internode"

mkdir -p /usr/local/share/gpsdrive
cd /usr/local/share/gpsdrive/

tar xzf "$TMP_DIR"/gpsdrive_syd_tileset-*.tar.gz

cd "$USER_HOME/.gpsdrive/"

# better to mkdir maps here then symlink in mapsets, with the big
#  mapnik/ one as read-only?? (so not loaded into RAM)
ln -s /usr/local/share/gpsdrive/maps "$USER_HOME/.gpsdrive/maps"

# allow users to download new data to /usr/local/share/gpsdrive
adduser $USER_NAME users
chown -R root.users /usr/local/share/gpsdrive/maps
chmod -R g+rwX /usr/local/share/gpsdrive/maps


# bypass Mapnik wanting 300mb World Boundaries DB to be installed
sed -e 4594,4863d "$TMP_DIR/gpsdrive-$VERSION/build/scripts/mapnik/osm-template.xml" \
  > "$USER_HOME/.gpsdrive/osm.xml"


#if [ $? -eq 0 ] ; then
#   rm -rf "$TMP_DIR"
#fi


chown -R $USER_NAME:$USER_NAME "$USER_HOME/.gpsdrive"

cp /usr/share/applications/gpsdrive.desktop "$USER_HOME/Desktop/"
chown $USER_NAME:$USER_NAME "$USER_HOME/Desktop/gpsdrive.desktop"



#### install OSM data for Mapnik Support ####
#
# - Download OSM planet file from
#  http://www.osmaustralia.org/osmausextract.php
#    or
#  http://downloads.cloudmade.com/oceania/australia
#
# - Set up PostGIS Database and import data
#  see https://sourceforge.net/apps/mediawiki/gpsdrive/index.php?title=Setting_up_Mapnik
#

echo "Finished installing GpsDrive."


cat << EOF

== Testing ==

=== If no GPS is plugged in ===
* Double click on the GpsDrive desktop icon
* You should see a map of downtown Sydney, after about 10 seconds
a waypoint marker for the Convention Centre should appear.
* Set the map scale to 1:10,000 either by dragging the slider at the
bottom or by using the +,- buttons (not magnifying glass)
* Enter Explore Mode by pressing the "e" key or in the Map Control button.
* Use the arrow keys or left mouse button to move off screen.
* Right click to set destination and leave Explore Mode

==== Downloading maps ====
* Change the scale setting to 1:1,000,000 you should see a continental map 
* Enter Explore Mode again ("e") and left click on the great barrier reef
* Options -> Map -> Download
** Map source: NASA LANDSAT, Scale: 1:500,000, [Download Map]
** When download is complete click [ok] then change the preferred scale
slider to 1:500,000
** This will be of more use in remote areas.
* Explore to the coast, click on an airport, headland, or some other
conspicuous feature. You might want to use the magnifying glass buttons
to zoom in on it better. Use a right click set the target on some other
conspicuous feature nearby then demagnify back out.
* Options -> Map -> Download
** Map source: OpenStreetMap, Scale: 1:150,000, left-click on map to center
the green preview over your target and what looks like a populated area.
** [Download Map]
** When download is complete click [ok] then change the preferred scale
slider to 1:150,000 and you should see a (rather rural) road map. This will
be more interesting in built up areas.

==== Overlay a GPX track ====
* In the ~/.gpsdrive/tracks/ directory you will find australia.gpx
which is a track line following the coastline.
* Options -> Import -> GPX track
* Hidden folders are hidden in the file picker, but just start typing
~/.gpsdrive and hit enter. You should then see the tracks/ directory
and be able to load australia.gpx.
* A red trace should appear along the coastline.
* Check that it lines up well with the coast as shown in map tiles of
varying scale.

=== If a GPS is plugged in ===
* Make sure gpsd is running by starting "xgps" from the command line.
* The program will automatically detect gpsd and jump to your current
position. This should bring up a continental map as you won't have any
map tiles downloaded for your area yet.
* See the above "Downloading Maps" section to get some local tiles.
* If you have a local GPX track of some roads try loading that and making
sure everything lines up, as detailed in the above "Overlay a GPX track"
section.

That's it.

EOF
