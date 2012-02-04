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
# sudo ./main.sh 2>&1 | tee /var/log/osgeolive/main_install.log

# Customisation:
# =============
# You can customise the contents of the liveDVD by deleting or adding install
# scripts to the list below. (I'd prefer to be able to comment the list out,
# but my scripting skills are not up to that.)

DIR=`dirname $0`
LOG_DIR="/var/log/osgeolive"
DOC_DIR="/var/www"
MAIN_LOG_FILE="main_install.log"
DISK_USAGE_LOG="disk_usage.log"


# 
# Detect language code from $LANG environment.
# It is used for showing welcoming message of running locale. (inside install_desktop.sh)
# Adding more supported language codes is needed.
# 
# It is not tested whether this change works. Please test.
#
case `echo $LANG | sed 's/_.*//'` in
    ja)
        LANG_CODE="ja"
        ;;
    de)
        LANG_CODE="de"
        ;;
    it)
        LANG_CODE="it"
        ;;
    es)
        LANG_CODE="es"
        ;;
    *)
        LANG_CODE="en"
        ;;
esac
export LANG_CODE

echo "===================================================================="
echo "Starting main.sh for version: `cat ${DIR}/../VERSION.txt`"
echo "===================================================================="
echo Disk Usage1:, main.sh, `df -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, main.sh, `df -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`

# Print out the current svn revision
#  (doesn't work with `svn export`)
if [ -d ../.svn ] ; then
   svn info ..
fi

# clear the decks
rm -rf /tmp/build_gisvm_error.log

# install order:
#  1. Base packages
#  2. Java apps
#  3. PostGIS apps
#  4. Desktop GIS apps
#  5. LiveDVD desktop, docs, etc.
#  6. Cleanup scripts

for SCRIPT in \
  ./setup.sh \
  ./install_services.sh \
  ./install_mysql.sh \
  ./install_java.sh \
  ./install_openjdk.sh \
  ./install_apache2.sh \
  ./install_tomcat6.sh \
  ./install_geoserver.sh \
  ./install_geomajas.sh \
  ./install_geonetwork.sh \
  ./install_deegree.sh \
  ./install_52nWPS.sh \
  ./install_kosmo.sh \
  ./install_udig.sh \
  ./install_openjump.sh \
  ./install_gvsig.sh \
  ./install_postgis.sh \
  ./install_osm.sh \
  ./load_postgis.sh \
  ./install_pgrouting.sh \
  ./install_sahana.sh \
  ./install_ushahidi.sh \
  ./install_mapserver.sh \
  ./install_mapbender.sh \
  ./install_geokettle.sh \
  ./install_gmt.sh \
  ./install_grass.sh \
  ./install_qgis.sh \
  ./install_qgis_mapserver.sh \
  ./install_saga.sh \
  ./install_mapnik.sh \
  ./install_mapproxy.sh \
  ./install_maptiler.sh \
  ./install_marble.sh \
  ./install_opencpn.sh \
  ./install_prune.sh \
  ./install_viking.sh \
  ./install_zygrib.sh \
  ./install_geopublisher.sh \
  ./install_atlasstyler.sh \
  ./install_liblas.sh \
  ./install_gpsdrive.sh \
  ./install_mapfish.sh \
  ./install_openlayers.sh \
  ./install_R.sh \
  ./install_ossim.sh \
  ./install_osgearth.sh \
  ./install_spatialite.sh \
  ./install_zoo-project.sh \
  ./install_52nSOS.sh \
  ./install_otb.sh \
  ./install_rasdaman.sh \
  ./install_tinyows.sh \
  ./install_52nWSS.sh \
  ./install_pycsw.sh \
  ./install_geomoose.sh \
  ./install_mb-system.sh \
  ./load_gisdata.sh \
  ./install_main_docs.sh \
  ./install_edutools.sh \
  ./install_desktop.sh \
  ./install_language.sh \
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
  #Prints in MB blocks now, -h might miss changes less than 1GB
  echo Disk Usage1:, $SCRIPT, `df -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
  echo Disk Usage2:, $SCRIPT, `df -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
done

# works, but ran out of disc space:
#    ./install_mapguide.sh  (currently doesn't work with natty)
#    ./install_mb-system.sh


# write installed package manifest
if [ ! -d "$DOC_DIR" ] ; then
   mkdir -p "$DOC_DIR"
fi
dpkg --get-selections > "$DOC_DIR/package_manifest.txt"


echo "==============================================================="
echo "Show top 75 packages hogging the most space on the disc:"
dpkg-query --show --showformat='${Package;-50}\t${Installed-Size}\t${Status}\n' \
  | sort -k 2 -n | grep -v deinstall | tac | head -n 75 | \
  awk '{printf "%.3f MB \t %s\n", $2/(1024), $1}'

# check install sizes
echo "==============================================================="
echo "Writing disk usage stats to $LOG_DIR/$DISK_USAGE_LOG ..."
echo "Disk Usage1:,package,Filesystem,1K-blocks,Used,Available,Use%,Mounted_on,date" \
       > "$LOG_DIR/$DISK_USAGE_LOG"
grep "Disk Usage2:" "$LOG_DIR/$MAIN_LOG_FILE" >> "$LOG_DIR/$DISK_USAGE_LOG"

echo "==============================================================="
# to be interesting this should really focus on diff to prior, not absolute value
echo "Package    |Megabytes used by install script" | tr '|' '\t'
grep "Disk Usage2:" ${LOG_DIR}/${MAIN_LOG_FILE} | \
  cut -f2,5 -d, | cut -f2- -d_ | \
  grep -v '^,\|main.sh\|setdown.sh' | sed -e 's/\.sh,/    \t/' | \
  awk 'BEGIN { PREV=0; } 
	{ if(PREV == 0) { PREV = $2; }
	printf("%s", $1);
	if($1 == "R" || $1 == "osm" || $1 == "gmt" || $1 == "otb") { printf("\t") }
	if($1 == "qgis_mapserver" || $1 == "geopublisher")
	     { printf("\t") }
	else { printf("    \t") }
	print $2 - PREV;
	PREV = $2 }' | sort  -nr -k2 | uniq

echo "==============================================================="

if [ -e /tmp/build_gisvm_error.log ] ; then
   echo
   cat /tmp/build_gisvm_error.log
else
   echo "No script failures detected."
fi

# grep for problems
echo "==============================================================="
grep -iwn 'ERROR\|^E:' "$LOG_DIR/$MAIN_LOG_FILE" | grep -v libgpg-error-dev
grep '^..: cannot stat' "$LOG_DIR/$MAIN_LOG_FILE"
grep '^cp: cannot create regular file' "$LOG_DIR/$MAIN_LOG_FILE"
grep "^sed: " "$LOG_DIR/$MAIN_LOG_FILE"
grep '^ls: cannot access' "$LOG_DIR/$MAIN_LOG_FILE"
grep -iwn 'FIXME\|failed' "$LOG_DIR/$MAIN_LOG_FILE"

echo
echo "==============================================================="
echo "Finished main.sh."
exit

########################################################
# Scripts past here are not installed yet
########################################################

# Build the iso should be done later
# ./build_iso.sh

