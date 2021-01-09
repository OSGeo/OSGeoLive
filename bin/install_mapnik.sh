#!/bin/sh
#############################################################################
#
# Purpose: This script will install Mapnik library, Python bindings and
# Tilestache for a demo 'World Borders' application
#
#############################################################################
# Copyright (c) 2009-2019 The Open Source Geospatial Foundation and others.
#
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
#############################################################################

#
# Requires:
# =========
# python, wget, unzip
#
# Uninstall:
# ==========
# sudo apt-get remove python-mapnik tilestache python-modestmaps
# rm -rf /usr/local/share/mapnik/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# download, install, and setup demo Mapnik tile-serving application
TMP="/tmp/build_mapnik"
DATA_FOLDER="/usr/local/share"
MAPNIK_DATA="$DATA_FOLDER/mapnik"
BIN="/usr/local/bin"

apt-get install --yes python-mapnik

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

# Patch for #2096
# not neededanymore sed -i -e 's/engine = mapnik.FontEngine.instance()/#engine = mapnik.FontEngine.instance()/' /usr/lib/python2.7/dist-packages/TileStache/Mapnik.py


if [ ! -d "$MAPNIK_DATA" ] ; then
   echo "Creating $MAPNIK_DATA directory"
   mkdir "$MAPNIK_DATA"
fi

chmod -R 755 "$MAPNIK_DATA

cat << EOF >"$MAPNIK_DATA/world_population.xml"
<!DOCTYPE Map>
<!-- Sample Mapnik XML template by Dane Springmeyer -->
<Map srs="+proj=latlong +datum=WGS84" background-color="white" minimum-version="0.7.2">
  <Style name="population">
     <!-- Built from Seven Class sequential YIGnBu from www.colorbrewer.org -->
     <!-- Quantile breaks originally from QGIS layer classification -->
     <Rule>
      <Filter>[pop_est] &gt; -1 and [pop_est] &lt; 15000</Filter>
      <PolygonSymbolizer fill="#c7e9b4"/>
      <LineSymbolizer stroke="black" stroke-width=".1"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 15000 and [pop_est] &lt; 255000</Filter>
      <PolygonSymbolizer fill="#7fcdbb"/>
      <LineSymbolizer stroke="black" stroke-width=".1"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 255000 and [pop_est] &lt; 1300000</Filter>
      <PolygonSymbolizer fill="#1d91c0"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 1300000 and [pop_est] &lt; 4320000</Filter>
      <PolygonSymbolizer fill="#41b6c3"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 4320000 and [pop_est] &lt; 9450000</Filter>
      <PolygonSymbolizer fill="#225ea8"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 9450000 and [pop_est] &lt; 25650000</Filter>
      <PolygonSymbolizer fill="#225ea8"/>
     </Rule>
     <Rule>
      <Filter>[pop_est] &gt;= 25650000 and [pop_est] &lt; 1134000000</Filter>
      <PolygonSymbolizer fill="#122F7F"/>
     </Rule>
     <Rule>
      <ElseFilter/> 
      <!-- This will catch all other values - in this case just India and China -->
      <!-- A dark red polygon fill and black outline is used here to highlight these two countries -->
      <PolygonSymbolizer fill="darkred"/>
      <LineSymbolizer stroke="black" stroke-width=".7"/>
     </Rule>
   </Style>
   <Style name="countries_label">
     <Rule>
      <!--  Only label those countries with over 9 Million People -->
      <!--  Note: Halo and Fill are reversed to try to make them subtle -->
      <Filter>[pop_est] &gt;= 4320000 and [pop_est] &lt; 9450000</Filter>
      <TextSymbolizer size="7" fill="black" face-name="DejaVu Sans Bold" halo-fill="#DFDBE3" halo-radius="1" wrap-width="20">[name]</TextSymbolizer>
     </Rule>
     <Rule>
      <!--  Only label those countries with over 9 Million People -->
      <!--  Note: Halo and Fill are reversed to try to make them subtle -->
      <Filter>[pop_est] &gt;= 9450000 and [pop_est] &lt; 25650000</Filter>
      <TextSymbolizer size="9" fill="black" face-name="DejaVu Sans Book" halo-fill="#DFDBE3" halo-radius="1" wrap-width="20">[name]</TextSymbolizer>
     </Rule>
     <Rule>
      <!--  Those with over 25 Million get larger labels -->
      <Filter>[pop_est] &gt;= 25650000 and [pop_est] &lt; 1134000000</Filter>
      <TextSymbolizer size="12" fill="white" face-name="DejaVu Sans Book" halo-fill="#2E2F39" halo-radius="1" wrap-width="20">[name]</TextSymbolizer>
     </Rule>
     <Rule>
      <!--  Those with over 25 Million get larger labels -->
      <!--  Note: allow_overlap is true here to allow India/China to sneak through -->
      <Filter>[pop_est] &gt;= 1134000000</Filter>
      <TextSymbolizer size="15" fill="white" face-name="DejaVu Sans Book" halo-fill="black" halo-radius="1" wrap-width="20" allow-overlap="true" avoid-edges="true">[name]</TextSymbolizer>
     </Rule>
  </Style>
  <Layer name="countries" srs="+proj=latlong +datum=WGS84" status="on">
    <!-- Style order determines layering hierarchy -->
    <!-- Labels go on top so they are listed second -->
    <StyleName>population</StyleName>
    <StyleName>countries_label</StyleName>
    <Datasource>
      <Parameter name="type">shape</Parameter>
      <Parameter name="file">/usr/local/share/data/natural_earth2/ne_10m_admin_0_countries.shp</Parameter>
    </Datasource>
  </Layer>
</Map>

