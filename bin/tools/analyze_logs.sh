#!/bin/sh
# Copyright (c) 2013-2018 The Open Source Geospatial Foundation.
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

LOG_DIR="/var/log/osgeolive"
MAIN_LOG_FILE="chroot-build.log"
DISK_USAGE_LOG="disk_usage.log"
TMP_USAGE_LOG="tmp_usage.log"
CALC_DISK_USAGE_LOG="disk_usage_calc.log"
DISK_USAGE_PLOT="disk_usage_plot.png"
TIME_PLOT="installation_time_plot.png"

# check install sizes
echo "==============================================================="
echo "Analyzing disk usage"
echo "Writing disk usage stats to $LOG_DIR/$DISK_USAGE_LOG ..."
echo "Disk Usage1: package,Filesystem,1K-blocks,Used,Available,Use%,Mounted_on,date" \
       > "$LOG_DIR/$DISK_USAGE_LOG"
grep "Disk Usage2:" "$LOG_DIR/$MAIN_LOG_FILE" >> "$LOG_DIR/$DISK_USAGE_LOG"
echo "Temp Usage: package,tmp disk space" \
       > "$LOG_DIR/$TMP_USAGE_LOG"
grep "Temp Usage:" "$LOG_DIR/$MAIN_LOG_FILE" >> "$LOG_DIR/$TMP_USAGE_LOG"
/usr/local/share/gisvm/bin/tools/diskspace_calc.py "$LOG_DIR/$DISK_USAGE_LOG" \
    "$LOG_DIR/$TMP_USAGE_LOG" "$LOG_DIR/$CALC_DISK_USAGE_LOG" "$LOG_DIR/$DISK_USAGE_PLOT" \
    "$LOG_DIR/$TIME_PLOT" --sort
# 
# echo "==============================================================="
# # to be interesting this should really focus on diff to prior, not absolute value
# echo "Package    |Megabytes used by install script" | tr '|' '\t'
# grep 'Disk Usage2:' "$LOG_DIR/$MAIN_LOG_FILE" | \
#   cut -f2,5 -d, | cut -f2- -d_ | \
#   grep -v '^,\|main.sh\|setdown.sh' | sed -e 's/\.sh,/    \t/' | \
#   awk 'BEGIN { PREV=0; } 
# 	{ if(PREV == 0) { PREV = $2; }
# 	printf("%s", $1);
# 	if($1 == "R" || $1 == "osm" || $1 == "gmt" || $1 == "otb") { printf("\t") }
# 	if($1 == "qgis_mapserver" || $1 == "geopublisher")
# 	     { printf("\t") }
# 	else { printf("    \t") }
# 	print $2 - PREV;
# 	PREV = $2 }' | sort  -nr -k2 | uniq
# 
# echo "==============================================================="

# grep for problems
echo "==============================================================="
echo "Searching logs for errors"
(
grep -iwn 'ERROR\|^E:' "$LOG_DIR/$MAIN_LOG_FILE" | \
   grep -v 'libgpg-error-dev\|DHAVE_STRERROR\|error.cc:'
grep '^..: cannot stat' "$LOG_DIR/$MAIN_LOG_FILE"
grep '^cp: cannot create regular file' "$LOG_DIR/$MAIN_LOG_FILE"
grep "^sed: " "$LOG_DIR/$MAIN_LOG_FILE"
grep '^ls: cannot access' "$LOG_DIR/$MAIN_LOG_FILE"
grep -iwn 'FIXME\|failed' "$LOG_DIR/$MAIN_LOG_FILE"
) > "$LOG_DIR"/main_log_errors.log 2> /dev/null

echo
echo "==============================================================="
echo "Finished analyzing logs."
#exit
