#!/bin/bash
# Copyright (c) 2009 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
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
#
# About:
# =====
# Preprocess the OSGeo-Live presentation and copy into the target directory.
# * Change URL of images files
# * Copy contributor and translator names into a HTML table on Credits slide,
#
# Usage:
# ======
# make_presentation <source dir> <target dir>

tmp=/tmp/make_presentation.tmp

# script assumes it is being run in the bin directory
cd "`dirname '$0'`/../doc"

cols=8 # Number of table columns
source="en/presentation" # source presentation file
if [ -d "$1" ] ; then
  source="$1";
fi
target="_build/html/en/presentation" # target presentation file
if [ -d "$2" ] ; then
  target="$2";
fi

mkdir -p "$target"

# copy the abstract.txt to the target
if [ ! -d "$target"/abstract.txt ] ; then
  cp --preserve=mode,timestamps -r "$source"/abstract.txt "$target"
fi

# copy the reveal.js libary to the target
if [ ! -d "$target"/../../reveal.js ] ; then
  cp --preserve=mode,timestamps -r "$source"/../../reveal.js "$target"/../..
fi

# Extract a list of names from contributors.csv and translators.csv
insertLine=`grep -n "Contributors and translators table is inserted here" "$source/index.html" | cut -d":" -f1`

# Replace space with @ so the name string is treated as one token in the for
# loop
cut -d"," -f1 ../doc/contributors.csv | sed -e "s/ /@/g ; s/Name//" > "$tmp"
cut -d"," -f3 ../doc/translators.csv | sed -e "s/ /@/g ; s/Name//" >> "$tmp"

# print top of the presentation file
head -n "$insertLine" "$source/index.html" > "$target/index.html"

j=0
echo "<table>" >> "$target/index.html"
for name in `cat "$tmp" | sort -u` ; do
  if [ $((j % cols )) -eq 0 ]; then 
    echo "<tr>" >> "$target/index.html"
  fi
  # insert space back into name string
  echo "<td>$name</td>" | sed -e "s/@/ /g" >> "$target/index.html"
  j=$((j + 1 ))
  if [ $((j % cols )) -eq 0 ]; then 
    echo "</tr>" >> "$target/index.html"
  fi
done
echo "</table>" >> "$target/index.html"

# print bottom of the presentation file
tail -n +"$insertLine" "$source/index.html" >> "$target/index.html"

mv "$target/index.html" "$tmp"

# copy the presentation images to the target
mkdir -p "$target/../../_images"
cp -p images/presentation/* "$target/../../_images"

# change all image URL references to be placed into _images/ dir
#<img src="../../images/screenshots/1024x768/mapwindow-screenshot.jpg"
# becomes <img src="_images/mapwindow-screenshot.jpg"
sed -e 's#\(<img.*\)\(src="../../images[^\.]*/\)\([^\.]*\.[^\/]*"\)#\1 src="../../_images/\3#' "$tmp" > "$target/index.html"

