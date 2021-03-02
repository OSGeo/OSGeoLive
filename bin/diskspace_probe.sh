#!/bin/sh
#############################################################################
#
# Purpose: Show how much disk space is free at the start and end of each 
#     install script.
#
# Author:  Hamish Bowman, 23 June 2013
#
#############################################################################
# Copyright (c) 2013  Hamish Bowman
# Copyright (c) 2013-2021 Open Source Geospatial Foundation (OSGeo) and others.
#
# Licensed under the GNU LGPL version >= 2.1.
# Previously this code existed in OSGeo Live DVD version 4-6's main.sh
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
#
# USAGE:   diskspace_probe.sh  <project_name> [begin|end]
#		if "begin" or "end" is not given it just does the
#		  df (for mid-script debug, etc).
#
# debug: run this on the chroot:
# df -h --print-type
#############################################################################

if [ $# -lt 1 ] || [ $# -gt 2 ] ; then
   echo "USAGE:   diskspace_probe.sh <project_name> [begin|end]" 1>&2
   exit 1
elif [ $# -eq 2 ] && [ "$2" != "begin" -a "$2" != "end" ] ; then
   echo "USAGE:   diskspace_probe.sh <project_name> [begin|end]" 1>&2
   exit 1
fi


do_hr() {
   echo "==============================================================="
}

df_cmd_regular() {
# TODO: check that cd /tmp/build_<project> gives same answer as in original build dir
   echo "Disk Usage1: $1,`df | head -n 1 | sed -e 's/ted on/ted_on/' -e 's/  */,/g'`,date"
   echo "Disk Usage2: $1,`df -B 1M / | tail -n +2 | sed -e 's/  */,/g'`,`date --rfc-3339=seconds`"
}

df_cmd_chroot() {
   echo "Disk Usage1: $1,`df . | head -n 1 | sed -e 's/ted on/ted_on/' -e 's/  */,/g'`,date"
   echo "Disk Usage2: $1,`df -B 1M . | tail -n +2 | sed -e 's/  */,/g'`,`date --rfc-3339=seconds`"
   echo "Temp Usage: $1,`du -s -B 1M /tmp`"
}

df_cmd() {
   df_cmd_chroot "$1"
}

if [ "$2" = "begin" ] ; then
   do_hr
   echo "Starting \"$1\" ..."
   do_hr

elif [ "$2" = "end" ] ; then
   do_hr
   echo "Finished \"$1\""
   df_cmd "$1"
   do_hr

else
   do_hr
   df_cmd "$1"
   do_hr

fi
