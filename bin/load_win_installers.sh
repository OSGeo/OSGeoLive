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


TMP=/tmp/build_win_installers

mkdir -p $TMP

for URL in \
  http://home.gdal.org/fwtools/FWTools243.exe \
  http://downloads.sourceforge.net/project/geonetwork/GeoNetwork_opensource/v2.4.1/geonetwork-install-2.4.1-0.exe?use_mirror=transact \
  http://downloads.sourceforge.net/project/geoserver/GeoServer/1.7.6/geoserver-1.7.6-ng.exe?use_mirror=transact \
  ftp://downloads.gvsig.org/gva/descargas/ficheros/11/gvSIG-update-1_1_2-windows-i586.exe \
  http://udig.refractions.net/files/downloads/udig-1.1.1.exe \
  \
  http://download.osgeo.org/qgis/win32/QGIS-1.2.0-0-No-GrassSetup.exe \
  http://home.gdal.org/tmp/vcredist_x86.exe \
  http://mirror.aarnet.edu.au/pub/grass/grass64/binary/mswindows/native/WinGRASS-6.4.0SVN-r39271-1-Setup.exe \
  http://maptools.org/dl/ms4w/ms4w_3.0_beta7.zip \
  http://download.osgeo.org/mapguide/releases/2.0.2/MgServerSetup-2.0.2.3011.exe \
; do
  wget -c --progress=dot:mega ${URL}
done;

  # FWTools
  # geonetwork
  # geoserver
  # gvSIG
  # ms4w
  # QGIS
  # udig
  # WinGRASS
  # MapGuide Open Source

  ### Possibles:
  # GpsBabel + GUI (1.2mb)
  #    http://www.gpsbabel.org/plan9.php?dl=gpsbabel-1.3.6.zip \
  # gpsVP: (500kb)  http://code.google.com/p/gpsvp/
  #    http://gpsvp.googlecode.com/files/gpsVPxp_0.4.18.zip \
