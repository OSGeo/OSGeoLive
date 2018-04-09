#!/bin/sh
# post_build_checks.sh
#
# Written by H.Bowman
# Copyright (c) 2014-2018 The Open Source Geospatial Foundation
# Licensed under the GNU LGPL version >= 2.1
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
# USAGE: Run from within the chroot.
#


LOG_DIR="/var/log/osgeolive"
mkdir -p "$LOG_DIR"


#### write installed package manifest
echo "# All installed packages on `hostname` (`date`)" \
   > "$LOG_DIR"/dpkg_package_manifest.txt
dpkg --get-selections >> "$LOG_DIR"/dpkg_package_manifest.txt


#### list the top 75 packages hogging the most space on the disc:
dpkg-query --show --showformat='${Package;-50}\t${Installed-Size}\t${Status}\n' \
  | sort -k 2 -n | grep -v deinstall | tac | head -n 75 | \
  awk '{printf "%.3f MB \t %s\n", $2/(1024), $1}' \
   > "$LOG_DIR"/deb_pkg_hogs.txt


#### find dead symlinks
find / -type l -xtype l | grep -v '/proc/\|/run/\|/rofs/' | \
   grep -v '/usr/share.*/help/' \
   > "$LOG_DIR"/dead_symlinks.log 2> /dev/null


#### find unknown UIDs and GIDs from running tar as root
# note that when run from within the original chroot env this
# won't find UID=1000, those only show up if run after mastering
# the iso.
find / -nouser 2> /dev/null | grep -v '^/rofs/' > "$LOG_DIR"/bad_UIDs.log
find / -nogroup 2> /dev/null | grep -v '^/rofs/'> "$LOG_DIR"/bad_GIDs.log


#### check how big the databases ended up
(
echo "Postgres database sizes:"
sudo -u postgres psql << EOF
SELECT pg_database.datname,
       pg_size_pretty(pg_database_size(pg_database.datname)) AS size
  FROM pg_database;
EOF
) > "$LOG_DIR"/pg_db_sizes.log

