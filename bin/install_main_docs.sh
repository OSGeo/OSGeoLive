#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Copyright (c) 2009 LISAsoft
# Copyright (c) 2009 Cameron Shorter
# Licensed under the GNU LGPL.
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

# About:
# =====
# This script will install documentation from 

# Running:
# =======
# sudo ./install_main_docs.sh

# Requires: nothing

USER_NAME="user"
USER_HOME="/home/$USER_NAME"
DEST="/usr/local/share/livedvd-docs"

mkdir -p $DEST/doc

#base
FILES="banner.png arramagong.css"

for ITEM in $FILES ; do
   # keep it at one file per line, as missing files tell us what is missing
   cp -f ../doc/"$ITEM" "$DEST/"
done
# index page start
cp -f ../doc/index_pre.html "$DEST/index.html"


### apps
#APPS="
#  deegree  geokettle  geonetwork  geoserver  gpsdrive
#  gmt  grass  gvsig  kosmo  mapfish  mapnik  mapserver
#  maptiler  mb-system  octave  opencpn  openlayers
#  osm  ossim  pgrouting  postgis  qgis  R  udig"

# automatically get app list from installer scripts:
SKIP="main_docs desktop java jdk apache2"
SKIP_STR=`echo "$SKIP" | sed -e 's/ /\\\|/g'`

APPS=`\ls -1 install_*.sh | cut -f2- -d_ | \
   sed -e 's/\.sh$//' | grep -vx "$SKIP_STR"`

for ITEM in $APPS ; do
   # keep it at one doc per line as missing files tell us which docs are missing
   \cp -f ../doc/descriptions/"${ITEM}_description.html" "$DEST/doc/"
   cat ../doc/descriptions/"${ITEM}_definition.html" >> "$DEST/index.html"
done

# index page end
cat ../doc/index_post.html >> "$DEST/index.html"



# FIXME
echo "install_main_docs.sh FIXME: Double-check that the Firefox \
home page is now set to file://$DEST/index.html"
# ~user/mozilla/ has to exist first, so firefox would have need
#   to been started at least once to set it up

# edit ~user/.mozilla/firefox/$RANDOM.default/prefs.js:
#   user_pref("browser.startup.homepage", "file:///usr/local/share/livedvd-docs/index.html");

PREFS_FILE=`find ~user/.mozilla/firefox/ | grep -w default/prefs.js | head -n 1`
if [ -n "$PREFS_FILE" ] ; then
   sed -i -e 's+\(homepage", "\)[^"]*+\1file:///usr/local/share/livedvd-docs/index.html+' \
      "$PREFS_FILE"

   # firefox snafu: needed for web apps to work if network is not there
   echo 'user_pref("toolkit.networkmanager.disable", true);' >> "$PREFS_FILE"
   # maybe being online won't stick, but we may as well try:
   echo 'user_pref("network.online", true);' >> "$PREFS_FILE"
fi

#Alternative, just put an icon on the desktop that launched firefox and points to index.html
\cp -f ../desktop-conf/arramagong-wombat-small.png  /usr/local/share/icons/


#What logo to use for launching the help? 
if [ ! -e /usr/share/applications/live_GIS_help.desktop ] ; then
   cat << EOF > /usr/share/applications/live_GIS_help.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Help
Comment=Live Demo Help
Categories=Application;Education;Geography;
Exec=firefox /usr/local/share/livedvd-docs/index.html
Icon=/usr/local/share/icons/arramagong-wombat-small.png
Terminal=false
StartupNotify=false
Categories=Education;Geography
EOF
fi

\cp -a /usr/share/applications/live_GIS_help.desktop "$USER_HOME/Desktop/"

#Should we embed the password file in the help somehow too?
