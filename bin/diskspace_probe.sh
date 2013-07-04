#!/bin/sh
#   diskspace_probe.sh
#      by Hamish Bowman, 23 June 2013
#   Copyright (c) 2013  Hamish Bowman, and The Open Source Geospatial Foundation
#   Licensed under the GNU LGPL >=2.1.
#   Previously this code existed in OSGeo Live DVD version 4-6's main.sh
#
# PURPOSE: Show how much disk space is free at the start and end of each install script.
#
# USAGE:   diskspace_probe.sh  <project_name> [begin|end]
#		if "begin" or "end" is not given it just does the
#		  df (for mid-script debug, etc).
#


#debug: run this on the chroot:
# df -h --print-type


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

df_cmd() {
# TODO: check that cd /tmp/build_<project> gives same answer as in original pwd
   echo "Disk Usage1: $1,`df -B 1M | grep 'Filesystem' | sed -e 's/  */,/g'`,date"
   echo "Disk Usage2: $1,`df -B 1M / | tail -n 1 | sed -e 's/  */,/g'`,`date --rfc-3339=seconds`"
}


if [ "$2" = "begin" ] ; then
   do_hr
   echo "Starting \"$1\""
   df_cmd "$1"
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
