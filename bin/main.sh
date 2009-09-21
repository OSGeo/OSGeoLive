#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This is the master GISVM script which will build a GISVM from a base
# Xubuntu system, by calling a series of scripts for each package
# For detailed build instructions, refer to:
#   http://wiki.osgeo.org/wiki/GISVM_Build#Creating_a_fresh_Virtual_Machine

# Running:
# =======
# sudo ./main.sh 2>&1 | tee /home/user/main_install.log

# Customisation:
# =============
# You can customise the contents of the liveDVD by deleting or adding install
# scripts to the list below. (I'd prefer to be able to comment the list out,
# but my scripting skills are not up to that.)

DIR=`dirname $0`
LOG_DIR="/var/log/arramagong"
MAIN_LOG_FILE="main_install.log"
DISK_USAGE_LOG="disk_usage.log"


echo "===================================================================="
echo "Starting master.sh for version: `cat ${DIR}/../VERSION.txt`"
echo "===================================================================="
echo Disk Usage1:, main.sh, `df | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, main.sh, `df | grep " /$" | sed -e "s/  */,/g"`, `date`

# Print out the current svn version
svn info

# clear the decks
rm -rf /tmp/build_gisvm_error.log

for SCRIPT in \
  ./setup.sh \
  ./install_java.sh \
  ./install_geoserver.sh \
  ./install_postgres.sh \
  ./install_main_docs.sh \
  ./install_apache2.sh \
  ./install_mapserver.sh \
  ./install_geonetwork.sh \
  ./install_deegree.sh \
  ./install_udig.sh \
  ./install_openjump.sh \
  ./install_geokettle.sh \
  ./install_grass.sh \
  ./install_mapnik.sh \
  ./install_kosmo.sh \
  ./install_maptiler.sh \
  ./install_marble.sh \
  ./install_qgis.sh \
  ./install_pgrouting.sh \
  ./install_gvsig.sh \
  ./install_gpsdrive.sh \
  ./install_mapfish.sh \
  ./setdown.sh \
; do
  echo "===================================================================="
  echo Starting: $SCRIPT
  echo "===================================================================="
  sh $SCRIPT
  if [ $? -ne 0 ] ; then
     echo '!!! possible failure in '"$SCRIPT" >> /tmp/build_gisvm_error.log
  fi
  echo Finished: $SCRIPT
  echo 
  echo Disk Usage1:, $SCRIPT, `df | grep "Filesystem" | sed -e "s/  */,/g"`, date
  echo Disk Usage2:, $SCRIPT, `df | grep " /$" | sed -e "s/  */,/g"`, `date`
done


# write installed package manifest
## better to write to /usr/local/share/livedvd-docs ?
DOC_DIR="/usr/share/livedvd-docs"
if [ ! -d "$DOC_DIR" ] ; then
   mkdir -p "$DOC_DIR"
fi
dpkg --get-selections > "$DOC_DIR/package_manifest.txt"


echo
echo "Finished main.sh."
echo "Run sudo vmware-toolbox, and select shrink, to shrink the image"
if [ -e /tmp/build_gisvm_error.log ] ; then
   echo
   cat /tmp/build_gisvm_error.log
fi

# grep for problems
grep -iwn ERROR main_install.log

exit

########################################################
# Scripts past here are not installed yet
########################################################

# install MB System - software for mapping the Sea Floor
# This is disabled until it can be built with shared libraries,
#   using static libraries it takes up 300mb.
./install_mb-system.sh

# check install sizes
grep "Disk Usage2:" ${LOG_DIR}/${MAIN_LOG_FILE} | tee ${LOG_DIR}/${DISK_USAGE_LOG}

echo "Package    |Kilobytes" | tr '|' '\t'
grep "Disk Usage2:" ${LOG_DIR}/${MAIN_LOG_FILE} | \
  cat disk_usage.csv | cut -f2,9 -d, | cut -f2- -d_ | \
  grep -v '^,\|setup.sh' | sed -e 's/\.sh,/    \t/' | sort -nr -k2   

