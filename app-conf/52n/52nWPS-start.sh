#!/bin/bash
#############################################################################
#
# Purpose: This script will start 52North WPS
#
#############################################################################
# Copyright (c) 2011-2018 The Open Source Geospatial Foundation.
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
#############################################################################

/usr/local/52nWPS/tomcat_start.sh restart

DELAY=30

(
for TIME in `seq $DELAY` ; do
  sleep 1
  echo "$TIME $DELAY" | awk '{print int(0.5+100*$1/$2)}'
done
) | zenity --progress --auto-close --text "52North WPS starting"

# how to set 5 sec timeout?
zenity --info --text "Starting web browser ..."

firefox "http://localhost:8083/wps/test.html"
