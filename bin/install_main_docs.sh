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
OSGEO_SVN="https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk"
DEST="/usr/local/share/livedvd-docs"

mkdir -p $DEST/doc

#base
FILES="banner.png arramagong.css"

for ITEM in $FILES ; do
#TODO: change wget to cp commands from local checkout required for build, keep it at one doc per line as missing files tell us which docs are missing
   #cp "/doc/$ITEM" "$DEST/$ITEM"
   wget -nv "$OSGEO_SVN/doc/$ITEM"  --output-document "$DEST/$ITEM"
done
# index page start
wget -nv -O - "$OSGEO_SVN/doc/index_pre.html" \
    > "$DEST/index.html"


# apps
APPS="deegree geokettle geonetwork geoserver gpsdrive grass gvsig kosmo mapfish mapnik mapserver maptiler openlayers pgrouting postgis qgis R udig ossim"

for ITEM in $APPS ; do
#TODO: change wget to cp commands from local checkout required for build, keep it at one doc per line as missing files tell us which docs are missing
   #not sure, is this an append
   wget -nv -O - "$OSGEO_SVN/doc/descriptions/${ITEM}_definition.html" \
       >> "$DEST/index.html"
   #cp "/doc/descriptions/${ITEM}_definition.html" "$DEST/doc/${ITEM}_description.html"   
   wget -nv "$OSGEO_SVN/doc/descriptions/${ITEM}_description.html" \
        --output-document "$DEST/doc/${ITEM}_description.html"

done

# index page end
wget -nv -O - "$OSGEO_SVN/doc/index_post.html" \
    >> "$DEST/index.html"



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
wget -nv "$OSGEO_SVN/desktop-conf/arramagong-wombat-small.png" \
   --output-document=/usr/local/share/icons/arramagong-wombat-small.png

#What logo to use for launching the help? 
if [ ! -e /usr/share/applications/gisvmhelp.desktop ] ; then
   cat << EOF > /usr/share/applications/gisvmhelp.desktop
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

cp -a /usr/share/applications/gisvmhelp.desktop "$USER_HOME/Desktop/"

#Should we embed the password file in the help somehow too?
