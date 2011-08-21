#!/bin/sh
#################################################
# 
# Purpose: Create a CSV table of licenses for OSGeo-Live documentation
# Author:  Cameron Shorter
#
#################################################
# Copyright (c) 2011 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2011 LISAsoft
#
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
##################################################

# Store the script root directory for later
cd `dirname "$0"`
BUILD_DIR=`pwd`

# Title
#echo '"Document","Authors(s)", Reviewer(s),"License(s)"'

for DIR in  ../doc/en/overview ../doc/en/quickstart ;  do
  cd "$BUILD_DIR/$DIR"

  for FILE in *.rst ;  do
    if [ "$FILE" = "overview.rst" ] ||  [ "$FILE" = "quickstart.rst" ] ; then
        continue
    fi

    # Document
    echo -n '"'
    echo -n "$FILE" | sed -e 's/.rst$//'
    echo -n '","'

    # Authors
    awk '/^:Author:/{printf("%s; ", $0)}' "$FILE" | \
      sed -e 's/:Author:\s*//g' -e 's/; $//'

    # Reviewers
    echo -n '","'
    awk '/^:Reviewer:/{printf("%s; ", $0)}' "$FILE" | \
      sed -e 's/:Reviewer:\s*//g' -e 's/; $//'

    # License(s)
    echo -n '","'
    awk '/^:License:/{printf("%s", $0)}' "$FILE" | \
      sed -e 's/:License:\s*//g'
    echo "\""

  done
done

