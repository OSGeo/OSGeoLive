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


#Add the files to the directory where remastersys wants them
#TMP="/tmp/build_mac_installers"
TMP="/tmp/remastersys/ISOTMP/MacInstallers"
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
frameworks/GDAL_Complete-1.8.dmg
frameworks/FreeType_Framework-2.4.6-1-snow.dmg
frameworks/cairo_Framework-1.10.2-3-snow.dmg
frameworks/GSL_Framework-1.15-2.dmg
frameworks/spatialite_tools-2.3.1.zip
frameworks/rgdal-0.6.33-3.zip
"

# 2 Support Packages
B_PKG="
postgresql/PostgreSQL-9.1.2-1.dmg
"

# 3 End-User Packages
C_PKG="
grass/GRASS-6.4.1-5-Snow.dmg
postgresql/PostGIS-1.5.3-2.dmg
qgis/Qgis-1.7.3-1.dmg
"


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


#Add uDig from another source
#( sorry udig, no space :-( )
#PKG="udig-1.2-M9.macosx.cocoa.x86.zip"
#wget -c --progress=dot:mega \
#   http://udig.refractions.net/files/downloads/branches/${PKG} -O "$PKG_DIR/$PKG"

#Add Ossim Stuff (Imagelinker, Ossimplanet)
PKG="imagelinker-1.7.15-appbundle.dmg"
wget -c --progress=dot:mega \
   http://download.osgeo.org/ossim/installers/mac/"$PKG" -O "$PKG_DIR/$PKG"
PKG="ossimplanet-appbundle-1.8.4.dmg"
wget -c --progress=dot:mega \
   http://download.osgeo.org/ossim/installers/mac/"$PKG" -O "$PKG_DIR/$PKG"

#Add GeoServer
# geoserver-2.0.2-bin.zip from ../WindowsInstallers/ is cross platform
# do symlinks work here?

#Add R-stats
PKG="R-2.14.1.pkg"
wget -c --progress=dot:mega \
   http://cran.stat.ucla.edu/bin/macosx/"$PKG" -O "$PKG_DIR/$PKG"
