#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# The script copies contributor and translator names into a HTML table,
# so that it can be inserted into a presentation.

TMP=/tmp/contributors_to_table.tmp

cols=8 # Number of table columns
source="../doc/en/presentation/index.html" # source presentation file
if [ $1 ] ; then
  source=$1;
fi
target="../doc/_build/html/en/presentation/index.html" # target presentation file
if [ $2 ] ; then
  target=$2;
fi

insertLine=`grep -n "Contributors and translators table is inserted here" $source | cut -d":" -f1`

# Extract a list of names from contributors.csv and translators.csv
# Replace space with @ so the name string is treated as one token in the for
# loop
cut -d"," -f1 ../doc/contributors.csv | sed -e "s/ /@/g ; s/Name//" > $TMP
cut -d"," -f3 ../doc/translators.csv | sed -e "s/ /@/g ; s/Name//" >> $TMP

# print top of the presentation file
head -n $insertLine $source > $target

j=0
echo "<table>" >> $target
for name in `cat $TMP` ; do
  if [ $((j % cols )) -eq 0 ]; then 
    echo "<tr>" >> $target
  fi
  # insert space back into name string
  echo "<td>$name</td>" | sed -e "s/@/ /g" >> $target
  j=$((j + 1 ))
  if [ $((j % cols )) -eq 0 ]; then 
    echo "</tr>" >> $target
  fi
done
echo "</table>" >> $target

# print bottom of the presentation file
tail -n +$insertLine $source >> $target

mv $target $TMP

# change all image URL references to be placed into _images/ dir
#<img src="../../images/screenshots/1024x768/mapwindow-screenshot.jpg"
# becomes <img src="_images/mapwindow-screenshot.jpg"
sed -e 's#\(<img.*\)\(src="../../images/[^\.]*/\)\([^\.]*\.[^\/]*"\)#\1 src="../../_images/\3#' $TMP > $target

