#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Author: Hamish Bowman <hamish_b yahoo com>
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
# This script will load Macintosh Installers for selected projects

# Running:
# =======
# cd ${CD}/mac
# sudo ./load_mac_installers.sh

# Requires: nothing

#Add the files to the directory where remastersys wants them
#TMP="/tmp/build_mac_installers"
TMP="/tmp/remastersys/ISOTMP/MacInstallers"
mkdir -p "$TMP"
cd "$TMP"

# 
# 1 Base Packages (Frameworks)
#    1_UnixImageIO_Framework-1.0.32a.dmg (UnixImageIO_Framework-1.0.32a.dmg)
#    2_PROJ_Framework-4.6.1-4.dmg (PROJ_Framework-4.6.1-4.dmg)
#    3_GEOS_Framework-3.1.1-4.dmg (GEOS_Framework-3.1.1-4.dmg)
#    4_SQLite3_Framework-3.6.17-3.dmg (SQLite3_Framework-3.6.17-3.dmg)
#    5_spatialite_tools-2.3.1.zip (spatialite_tools-2.3.1.zip)
#    6_FreeType_Framework-2.3.9-2.dmg (FreeType_Framework-2.3.9-2.dmg)
#    7_GDAL_Framework-1.6.2-3.dmg (GDAL_Framework-1.6.2-3.dmg)
#    8_rgdal-0.6.12-1.zip (rgdal-0.6.12-1.zip)
# 2 Support Packages
#    PHP5-5.2.10-3.dmg
#    PostgreSQL-8.3.8-1.dmg
# 3 End-User Packages
#    GRASS-6.4-RC5-3-Leo.dmg
#    GRASS-6.4-RC5-2-Snow.dmg
#    MapServer-5.4.2-2.dmg
#    pgRouting-1.0.3-3(PG8.3).dmg
#    PostGIS-1.4.0-4(PG8.3).dmg
#    Qgis-1.3.0-1-Leopard.dmg
#    Qgis-1.3.0-2-Snow.dmg
#

BASE_URL="http://www.kyngchaos.com/files/software/unixport"


cat << EOF > README.txt
OSGeo Macintosh installers for OSX Leopard and Snow Leopard

 by William Kyngesburye
    http://www.kyngchaos.com


TO INSTALL:

Install the base packages (Frameworks) first, followed by the support
packages, and finally the end-user programs. The base packages must be
installed in order.

Not all Frameworks and support packages are needed for all end user
programs. Consult the above website for details.

The framework packaging method is a bit more trouble up front, but
ensures the minimum amount of disk space is used by programs which
share common support libraries, and that these components can be safely
upgraded in future without rendering the other programs unusable.


Happy Mapping!
EOF


A_PKG="
UnixImageIO_Framework-1.0.32a.dmg
PROJ_Framework-4.6.1-4.dmg
GEOS_Framework-3.1.1-4.dmg
SQLite3_Framework-3.6.17-3.dmg
spatialite_tools-2.3.1.zip
FreeType_Framework-2.3.9-2.dmg
GDAL_Framework-1.6.2-3.dmg
rgdal-0.6.12-1.zip
"

B_PKG="PHP5-5.2.10-3.dmg PostgreSQL-8.3.8-1.dmg"

C_PKG="
GRASS-6.4-RC5-3-Leo.dmg
GRASS-6.4-RC5-2-Snow.dmg
MapServer-5.4.2-2.dmg
pgRouting-1.0.3-3(PG8.3).dmg
PostGIS-1.4.0-4(PG8.3).dmg
Qgis-1.3.0-1-Leopard.dmg
Qgis-1.3.0-2-Snow.dmg
"


### Base Packages
PKG_DIR="A__Base_Packages"
mkdir "$PKG_DIR"

i=0
for PKG in $A_PKG ; do
  i=`expr $i + 1`
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/${i}_$PKG"
  sleep 1
done


### Support Packages
PKG_DIR="B__Support_Packages"
mkdir "$PKG_DIR"

for PKG in $B_PKG ; do
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/$PKG"
  sleep 1
done


### End User Packages
PKG_DIR="C__End_User_Packages"
mkdir "$PKG_DIR"

for PKG in $C_PKG ; do
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/$PKG"
  sleep 1
done

