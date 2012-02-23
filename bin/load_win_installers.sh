#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Copyright (c) 2009 LISAsoft
# Copyright (c) 2009 Cameron Shorter
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
# This script will load Windows Installers for selected projects

# Running:
# =======
# cd ${CD}/win
# sudo ./load_win_installers.sh

# Requires: nothing

#Add the files to the directory where remastersys wants them
#TMP="/tmp/build_win_installers"
TMP="/tmp/remastersys/ISOTMP/WindowsInstallers"
mkdir -p $TMP
cd $TMP

#echo "OSGeo software for Windows:  http://trac.osgeo.org/osgeo4w/" > README.txt
cat << EOF > README.txt
OSGeo Windows installers

 by Alex Mandel

TO INSTALL:
To install the application simply double click on the appropriate exe or
unzip a zip and read the README for each application. Some applications
have 64bit version but only 32bit have been included here for
compatibility, check the web for newer or alternate versions. For more
information about the projects please read the help included in the live
disc or visit http://live.osgeo.org

osgeo4w-setup.exe is an application to help you install applications on
windows. Some of the same applications included here are also available
via OSGeo4w. The OSGeo4w tool includes the ability to manage upgrades,
install additional libraries and ensure compatability between mulitple
applications. Visit http://trac.osgeo.org/osgeo4w/ for more information.

vcredist_x86.exe is the  Runtime from Microsoft, it is required for many
of the other applications to work.

GeoServer:  geoserver-2.0.2-bin.zip in the Windows Installers cache also
works on a Mac.

Happy Mapping!
EOF


for URL in \
  http://download.osgeo.org/osgeo4w/osgeo4w-setup.exe \
  http://forge.osor.eu/frs/download.php/1570/gvSIG-1_11-1305-final-win-i586-j1_5.exe \
  http://www.qgis.org/downloads/QGIS-OSGeo4W-1.7.3-00624b3-Setup.exe \
  http://home.gdal.org/tmp/vcredist_x86.exe \
  http://grass.osgeo.org/grass64/binary/mswindows/native/WinGRASS-6.4.1-1-Setup.exe \
  http://download.osgeo.org/livedvd/data/gpsbabel/GPSBabel-1.4.2-Setup.exe \
  http://gpsvp.googlecode.com/files/gpsVPxp_0.4.24.zip \
  http://downloads.sourceforge.net/project/opencpn/opencpn/2.5.0/opencpn_2.5.0_setup.exe?use_mirror=cdnetworks-us-2 \
  http://download.osgeo.org/ossim/installers/windows/ossimplanet-installer-1.8.4.exe \
  http://sourceforge.net/projects/saga-gis/files/SAGA%20-%202.0/SAGA%202.0.8/saga_2.0.8_win32_setup.exe?use_mirror=cdnetworks-us-2 \
  "http://download.codeplex.com/Download?ProjectName=mapwindow4&DownloadId=300267&FileTime=129649216070600000&Build=18416" \
; do
  # sourceforge filename sanitation:
  OUTFILE=`basename "$URL" | cut -f1 -d'?'`

  wget -c --progress=dot:mega "$URL" -O "$OUTFILE"
done;

#Disabled because they are very outdated
# http://maptiler.googlecode.com/files/maptiler-1.0-beta2-setup.exe
# http://home.gdal.org/fwtools/FWTools247.exe \

#FIXME:
#\mv "plan9.php?dl=gpsbabel-1.3.6.zip" gpsbabel-1.3.6.zip

#( sorry udig and kosmo, no space :-( )
#  http://www.kosmoland.es/public/kosmo/v_2.0/binaries/Kosmo_Desktop_2.0_windows_jre.zip \
#  http://udig.refractions.net/files/downloads/udig-1.1.1.exe \


  # FWTools
  # geonetwork
  # geoserver
  # GpsBabel + GUI (1.2mb)
  # gpsVP: (500kb)  http://code.google.com/p/gpsvp/
  # gvSIG
  # Kosmo
  # MapGuide Open Source
  # MapGuide Open Source (120mb)
  # MapTiler
  # ms4w
  # OpenCPN (8mb)
  # Ossim (30mb)
  # QGIS
  # SAGA (5.6mb)
  # udig
  # WinGRASS

