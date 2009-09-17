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


OSGEO_SVN="https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk"
DEST="/usr/share/livedvd-docs"

mkdir -p $DEST

#base
FILES="banner.png arramagong.css"

for ITEM in $FILES ; do
   wget -r "$OSGEO_SVN/doc/$ITEM"  --output-document "$DEST/$ITEM"
done
# index page start
wget -nv -O - "$OSGEO_SVN/doc/index_pre.html" \
    > "$DEST/index.html"


# apps
APPS="deegree geokettle geoserver gpsdrive grass gvsig mapfish mapserver maptiler pgrouting postgis qgis R udig"

for ITEM in $APPS ; do
   wget -nv -O - "$OSGEO_SVN/doc/descriptions/${ITEM}_definition.html" \
       >> "$DEST/index.html"

   wget -r "$OSGEO_SVN/doc/descriptions/${ITEM}_description.html" \
        --output-document "$DEST/${ITEM}_description.html"
done

# index page end
wget -nv -O - "$OSGEO_SVN/doc/index_post.html" \
    >> "$DEST/index.html"



# FIXME
echo "install_main_docs.sh FIXME: Double-check that the Firefox \
home page is now set to file:///usr/share/livedvd-docs/index.html"
# ~user/mozilla/ has to exist first, so firefox would have need
#   to been started at least once to set it up

# edit ~user/.mozilla/firefox/$RANDOM.default/prefs.js:
#   user_pref("browser.startup.homepage", "file:///usr/share/livedvd-docs/index.html");

PREFS_FILE=`find ~user/.mozilla/firefox/ | grep -w default/prefs.js | head -n 1`
if [ -n "$PREFS_FILE" ] ; then
   sed -i -e 's+\(homepage", "\)[^"]*+\1file:///usr/share/livedvd-docs/index.html+' \
      "$PREFS_FILE"
fi

