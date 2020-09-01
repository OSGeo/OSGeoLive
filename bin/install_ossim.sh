#!/bin/sh
#
# install_ossim.sh
#
#############################################################################
# Created by Massimo Di Stefano on 07/12/09.
# Copyright (c) 2010-2020 Open Source Geospatial Foundation (OSGeo) and others.
#
# Licensed under the GNU LGPL version >= 2.1.
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

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_ossim
APP_DATA_DIR="$BUILD_DIR/../app-data/ossim"
DATA_FOLDER="/usr/local/share/data"

#### install ossim from ppa
apt-get -q update

apt-get install --yes ossim-core
# apt-get install --yes libossim1 ossim-plugins ossim-planet-qt \
#     ossim-planet ossim-gui

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   "$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
   exit 1
fi

#### download ossim icons
# mkdir -p "$TMP_DIR"
# mkdir -p /usr/share/ossim
# cd "$TMP_DIR"

# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossimPlanet.xpm"
# mv ossimPlanet.xpm /usr/share/pixmaps/ossimPlanet.xpm
# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossim.xpm"
# mv ossim.xpm /usr/share/pixmaps/ossim.xpm

# create launchers

# cat << EOF > /usr/share/applications/imagelinker.desktop
# [Desktop Entry]
# Version=1.0
# Name=Imagelinker
# Comment=OSSIM imagelinker
# Exec=/usr/bin/imagelinker -P /usr/share/ossim/ossim_preference
# Icon=ossim
# Terminal=false
# Type=Application
# StartupNotify=true
# Categories=Education;Science;Geography;
# GenericName=
# EOF

# cp -a /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
# chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/imagelinker.desktop"

# cat << EOF > /usr/share/applications/ossimplanet.desktop
# [Desktop Entry]
# Version=1.0
# Name=OssimPlanet
# Comment=OSSIM Planet
# Exec=/usr/bin/ossimplanet -P /usr/share/ossim/ossim_preference
# Icon=ossimPlanet
# Terminal=false
# Type=Application
# StartupNotify=true
# Categories=Education;Science;Geography;
# GenericName=
# EOF

# cp -a /usr/share/applications/ossimplanet.desktop "$USER_HOME/Desktop/"
# chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/ossimplanet.desktop"

# cat << EOF > /usr/share/applications/ossim-geocell.desktop
# [Desktop Entry]
# Version=1.0
# Name=OSSIM-geocell
# Comment=OSSIM-geocell
# Exec=/usr/bin/ossim-geocell -P /usr/share/ossim/ossim_preference
# Icon=ossim
# Terminal=false
# Type=Application
# StartupNotify=true
# Categories=Education;Science;Geography;Network;Graphics;Qt;
# GenericName=
# EOF

# cp -a /usr/share/applications/ossim-geocell.desktop "$USER_HOME/Desktop/"
# chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/ossim-geocell.desktop"

# wget --progress=dot:mega http://download.osgeo.org/livedvd/data/ossim/ossim_preference -O /usr/share/ossim/ossim_preference

# OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"
# export OSSIM_PREFS_FILE

# BRCFILE="/etc/skel/.bashrc"
# echo 'export OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$BRCFILE"
# #echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> "$BRCFILE"
# echo 'export OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$USER_HOME/.bashrc"
# #echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> "$USER_HOME/.bashrc"

# ln -s /usr/share/ossim/images/reference/bluemarble.tif \
#   /usr/local/share/data/raster/

# #Download data used to test the application
# KML_DATA="$DATA_FOLDER/kml"
# RASTER_DATA="$DATA_FOLDER/raster"
# ELEV_DATA=/usr/share/ossim/elevation/elev
# SAT_DATA="$RASTER_DATA/cape_cod"
# #echo "FIXME: does VRT data actually ship anymore?"
# VRT_DATA="$DATA_FOLDER/vrt"
# QUICKSTART=/usr/share/ossim/quickstart

# #mkdir -p "$KML_DATA"
# mkdir -p "$RASTER_DATA"
# #mkdir -p "$SAT_DATA"
# mkdir -p "$ELEV_DATA"   # ?? unused ??
# mkdir -p "$VRT_DATA"


# # disabled: $KML_DATA $SAT_DATA
# for ITEM in $RASTER_DATA $ELEV_DATA $VRT_DATA ;  do
#    chmod -R 775 "$ITEM"
#    chgrp -R users "$ITEM"
# done


# Cape Cod SRTM and LANDSAT  (this part is disble because of disc space issue)

#DATA_URL="http://download.osgeo.org/livedvd/data/ossim/"
#BASENAME="p011r031_7t19990918_z19_nn"
##for BAND in 10 20 30 ; do
##    # LANDSAT
##    wget --progress=dot:mega "$DATA_URL/ossim_data/${BASENAME}$BAND.tif" \
##         --output-document="$SAT_DATA/${BASENAME}$BAND.tif"
##    ls -l "$SAT_DATA/${BASENAME}$BAND.tif"
##    chmod a-x "$SAT_DATA/${BASENAME}$BAND.tif"
##done

# SRTM
##wget --progress=dot:mega "$DATA_URL/ossim_data/SRTM_fB03_p011r031.tif"  \
##     --output-document="$SAT_DATA/SRTM_fB03_p011r031.tif"
##chmod a-x "$SAT_DATA/SRTM_fB03_p011r031.tif"

#wget --progress=dot:mega $DATA_URL/ossim_data/bluemarble.tif  \
#--output-document=/usr/share/ossim/images/reference/bluemarble.tif

#wget --progress=dot:mega $DATA_URL/kml/Plaza_de_Cataluna.kmz \
#  --output-document=$KML_DATA/Plaza_de_Cataluna.kmz
#wget --progress=dot:mega $DATA_URL/kml/View_towards_Sagrada_Familia.kmz \
#  --output-document=$KML_DATA/View_towards_Sagrada_Familia.kmz

#wget --progress=dot:mega $DATA_URL/ossim_data/landsatrgb.prj \
#     --output-document=$PKG_DATA/landsatrgb.prj
#wget --progress=dot:mega $DATA_URL/ossim_data/session.session \
#     --output-document=$PKG_DATA/session.session


#OSSIM_PREFS_FILE=/usr/local/share/ossim/ossim_preference
#export OSSIM_PREFS_FILE

#if [ -e "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" ] ; then
# /usr/bin/ossim-img2rr \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"

# /usr/bin/ossim-create-histo \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
#    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"
#fi


# it turns up there anyway?
#/usr/bin/gdal_translate -of VRT "$RASTER_DATA"/BlueMarble_small.tif \
#    /usr/local/share/ossim/images/reference/bluemarble.tif


# mkdir -p "$QUICKSTART"/workspace
# chmod g+w "$QUICKSTART"/workspace
# chgrp users "$QUICKSTART"/workspace

# chmod g+w /usr/share/ossim/elevation
# chgrp users /usr/share/ossim/elevation


## TODO: Port the following to GRASS7 - this part needs gdal-grass plugin (not yet available for grass 7.x)

# #### spearfish subset to VRT
# GISBASE=/usr/lib/grass64
# export GISBASE
# SPEARFISH_RASTER="/usr/local/share/grass/spearfish60/PERMANENT/cellhd"
# 
# for MAP in "$SPEARFISH_RASTER"/* ; do
#     gdal_translate -of VRT "$MAP" "$VRT_DATA/`basename $MAP`.vrt"
# done
# 
# FILES=`ls "$VRT_DATA"/*.vrt`
# /usr/bin/ossim-img2rr $FILES
# /usr/bin/ossim-create-histo $FILES
# 
# 
# /usr/bin/gdal_translate -of VRT \
#     "$SPEARFISH_RASTER"/elevation.10m \
#     "$QUICKSTART"/workspace/elevation10m.vrt
# 
# /usr/bin/gdal_translate -of GTIFF -ot Float64 \
#     "$QUICKSTART"/workspace/elevation10m.vrt \
#     "$QUICKSTART"/workspace/elevation10m.tif
# 
# OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference \
#   /usr/bin/ossim-orthoigen -w general_raster_bip \
#     "$QUICKSTART"/workspace/elevation10m.tif \
#     /usr/share/ossim/elevation/spearfish/elevation10m.ras


# # add suppport files used for the ossim tutorials
# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/ossim_data/rgb.prj"
# mv rgb.prj "$QUICKSTART"/workspace/
# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/ossim_data/rgb.spec"
# mv rgb.spec "$QUICKSTART"/workspace/
# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/ossim_data/ossim-dem-color-table-template.kwl"
# mv ossim-dem-color-table-template.kwl "$QUICKSTART"/workspace/

# unset OSSIM_PREFS_FILE

# cp -r "$APP_DATA_DIR"/* "$QUICKSTART"/
# if [ -L "$USER_HOME/ossim" ] ; then
#    rm -f "$USER_HOME"/ossim
# fi
# ln -s "$QUICKSTART" "$USER_HOME"/ossim
# # does the above symlink need to be owned by $USER?
# if [ -L /etc/skel/ossim ] ; then
#    rm -f /etc/skel/ossim
# fi
# ln -s "$QUICKSTART" /etc/skel/ossim

# for dir in "$QUICKSTART" "$RASTER_DATA" "$DATA_FOLDER" ; do
#   chgrp -R users $dir
#   chmod -R g+w $dir
# done


# ossim-geocell tutorial
#wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/OSSIMGeoCell__User_Manual__1.8.18-1.pdf
#mv OSSIMGeoCell__User_Manual__1.8.18-1.pdf /usr/share/ossim/

# ossim tutorial
# wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/ossim_users_guide.pdf
# mv ossim_users_guide.pdf /usr/share/ossim/

# ossimplanet tutorial
#wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/ossimPlanetUsers.pdf
#mv ossimPlanetUsers.pdf /usr/share/ossim/

# chmod 644 /usr/share/ossim/*.pdf
# mkdir -p /var/www/html/ossim/
# ln -s -f /usr/share/ossim/*.pdf /var/www/html/ossim/

# wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/ossim.tar.gz"
# tar -zxvf ossim.tar.gz
# mv ossim/* /usr/share/ossim/
# rm -rf ossim ossim.tar.gz



# #### cleanup
# rm -rf "$QUICKSTART"/.svn


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end

