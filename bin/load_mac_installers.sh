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


if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: load_mac_installers.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

#Add the files to the directory where remastersys wants them
#TMP="/tmp/build_mac_installers"
#TMP="/tmp/remastersys/ISOTMP/MacInstallers"
#Add the files where geniso remaster needs them
TMP="MacInstallers"
mkdir -p "$TMP"
cd "$TMP"

BASE_URL="http://www.kyngchaos.com/files/software"

cat << EOF > README.txt
OSGeo Macintosh installers for OSX Snow Leopard

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

Current files install on Snow Leopard (10.6) or newer.

Happy Mapping!
EOF


# 1 Base Packages (Frameworks)
A_PKG="
frameworks/GDAL_Complete-1.11.dmg
frameworks/Spatialite_Tools-4.1.zip
"
##frameworks/rgdal-0.8.16-1.dmg
##frameworks/FreeType_Framework-2.4.12-1.dmg
##frameworks/cairo_Framework-1.12.2-1.dmg
##frameworks/GSL_Framework-1.16-1.dmg
##frameworks/TclTk_Aqua-8.5.8-2.dmg

# 2 Support Packages
B_PKG="
postgresql/PostgreSQL-9.3.4-1.dmg
python/PIL-1.1.7-4.dmg
python/matplotlib-1.3.1-2.dmg
"

# 3 End-User Packages
C_PKG="
postgresql/PostGIS-2.1.4-2.dmg
qgis/QGIS-2.8.3-1.dmg
"
##grass/GRASS-6.4.4-1-Lion.dmg

### Base Packages
PKG_DIR="A__Base_Packages"
mkdir "$PKG_DIR"

i=0
for PKG in $A_PKG ; do
  i=`expr $i + 1`
  #Split the prefix off
  END=${PKG##*/}
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/${i}_$END"
  sleep 1
done


### Support Packages
PKG_DIR="B__Support_Packages"
mkdir "$PKG_DIR"

for PKG in $B_PKG ; do
  #Split the prefix off
  END=${PKG##*/}
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/$END"
  sleep 1
done


### End User Packages
PKG_DIR="C__End_User_Packages"
mkdir "$PKG_DIR"

for PKG in $C_PKG ; do
  #Split the prefix off
  END=${PKG##*/}
  wget -c --progress=dot:mega "$BASE_URL/$PKG" \
    -O "$PKG_DIR/$END"
  sleep 1
done


#############################################
#Add uDig from another source
PKG="udig-1.4.0.macosx.cocoa.x86_64.zip"
#sorry, no space left this time
#wget -c --progress=dot:mega \
#   http://udig.refractions.net/files/downloads/"$PKG" -O "$PKG_DIR/$PKG"


#############################################
#Add Ossim Stuff (Imagelinker, Ossimplanet)
PKG="imagelinker-1.7.15-appbundle.dmg"
# wget -c --progress=dot:mega \
#    http://download.osgeo.org/ossim/installers/mac/"$PKG" -O "$PKG_DIR/$PKG"
PKG="ossimplanet-appbundle-1.8.4.dmg"
# wget -c --progress=dot:mega \
#    http://download.osgeo.org/ossim/installers/mac/"$PKG" -O "$PKG_DIR/$PKG"


#############################################
#Add GeoServer
# geoserver-*-bin.zip from ../WindowsInstallers/ is cross platform
# ? do symlinks work here ?


#############################################
#Add R-stats
PKG="R-3.1.1-mavericks.pkg"
#sorry, no space left this time
#wget -c --progress=dot:mega \
#   http://cran.stat.ucla.edu/bin/macosx/"$PKG" -O "$PKG_DIR/$PKG"

#############################################
#Add TileMill
PKG="TileMill-0.10.1.zip"
# wget -c --no-check-certificate --progress=dot:mega \
#   "http://github.com/downloads/mapbox/tilemill/$PKG" -O "$PKG_DIR/$PKG"
# alt: http://tilemill.s3.amazonaws.com/latest/TileMill-0.10.1.zip

#############################################
#Add GPSBabel (25mb)
PKG="GPSBabel-1.5.1.dmg"
# wget -c --progress=dot:mega \
#   "http://download.osgeo.org/livedvd/data/gpsbabel/$PKG" -O "$PKG_DIR/$PKG"

