#!/bin/sh
#
# install_ossim.sh
#
# Created by Massimo Di Stefano on 07/12/09.
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

#USER_NAME="user"

USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_ossim
APP_DATA_DIR="$BUILD_DIR/../app-data/ossim"
DATA_FOLDER="/usr/local/share/data"
OSSIM_VERSION=1.8.19
BUILD_DATE=20150707

apt-get -q update

apt-get install --assume-yes libtiff5 libfreetype6 libcurl3 libexpat1 libpng3 libfftw3-3  \
                             libgeotiff2 libqt4-core libqt4-opengl libpodofo0.9.0 libopenscenegraph99 \
                             libopenthreads14 libc6 libgcc1 libstdc++6 libgdal1h libgeos-c1 libgeos-3.4.2

#### download ossim
mkdir -p /tmp/build_ossim
cd /tmp/build_ossim


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi


if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_java.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_ossim.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"



wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/deb/gpstk_2.5_$ARCH.deb"	     
dpkg -i gpstk_2.5_$ARCH.deb

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/deb/ossim_1.18.19_$ARCH.deb"	     
dpkg -i ossim_1.18.19_$ARCH.deb

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/deb/ossim-share_1.18.19_all.deb"	     
dpkg -i ossim-share_1.18.19_all.deb

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/imagelinker.desktop"
mv imagelinker.desktop /usr/share/applications/imagelinker.desktop

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossimplanet.desktop"
mv ossimplanet.desktop /usr/share/applications/ossimplanet.desktop

wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossim-geocell.desktop"
mv ossim-geocell.desktop /usr/share/applications/ossim-geocell.desktop


wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossimPlanet.xpm"
mv ossimPlanet.xpm /usr/share/pixmaps/ossimPlanet.xpm
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/ossim/launchers/ossim.xpm"
mv ossim.xpm /usr/share/pixmaps/ossim.xpm

OSSIM_PREFS_FILE="/usr/local/share/ossim/ossim_preference"
export OSSIM_PREFS_FILE


# install main dependencies

#apt-get install --assume-yes libtiff5 libgeotiff2 \
#  libfreetype6 libcurl3 libopenscenegraph99 libqt4-opengl \
#  libexpat1 libpng3 libfftw3-3 \
#  libopenmpi1.6 libqt4-qt3support # opencv hdf5 png jpeg podofo openkpeg2 gdal

#apt-get install --assume-yes krb5-multidev libexpat-ocaml libfindlib-ocaml \
#  libgnutls-openssl27 libopenjpeg2 libpodofo0.9.0 \
#  libqt4-sql-sqlite libtiffxx5 ocaml-base-nox \
#  ocaml-findlib ocaml-interp ocaml-nox pkg-config \
#  libqt4-core

#apt-get --assume-yes install libjpeg62

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   "$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
   exit 1
fi

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ldconfig

BRCFILE="/etc/skel/.bashrc"
echo 'export OSSIM_PREFS_FILE="/usr/local/share/ossim/ossim_preference"' >> "$BRCFILE"
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> "$BRCFILE"
echo 'export OSSIM_PREFS_FILE="/usr/local/share/ossim/ossim_preference"' >> "$USER_HOME/.bashrc"
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> "$USER_HOME/.bashrc"

ln -s /usr/local/share/ossim/images/reference/bluemarble.tif \
  /usr/local/share/data/raster/   

cp /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/imagelinker.desktop"

cp /usr/share/applications/ossimplanet.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/ossimplanet.desktop"

cp /usr/share/applications/ossim-geocell.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/ossim-geocell.desktop"

# add menu item
if [ ! -e /usr/share/menu/imagelinker ] ; then
   cat << EOF > /usr/share/menu/imagelinker
?package(imagelinker):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="Imagelinker"\
  command="/usr/local/ossim/bin/imagelinker"\
  icon="/usr/share/pixmaps/ossim.xpm"
EOF
  update-menus
fi

if [ ! -e /usr/share/menu/ossimplanet ] ; then
   cat << EOF > /usr/share/menu/ossimplanet
?package(ossimplanet):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="Ossimplanet"\
  command="/usr/local/ossim/bin/ossimplanet"\
  icon="/usr/share/pixmaps/ossimPlanet.xpm"
EOF
  update-menus
fi

if [ ! -e /usr/share/menu/ossim-geocell ] ; then
   cat << EOF > /usr/share/menu/ossim-geocell
?package(imagelinker):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="Imagelinker"\
  command="/usr/local/ossim/bin/ossim-geocell"\
  icon="/usr/share/pixmaps/ossim.xpm"
EOF
  update-menus
fi


#Download data used to test the application
KML_DATA="$DATA_FOLDER/kml"
RASTER_DATA="$DATA_FOLDER/raster"
ELEV_DATA=/usr/local/share/ossim/elevation/elev
SAT_DATA="$RASTER_DATA/cape_cod"
#echo "FIXME: does VRT data actually ship anymore?"
VRT_DATA="$DATA_FOLDER/vrt"
QUICKSTART=/usr/local/share/ossim/quickstart

#mkdir -p "$KML_DATA"
mkdir -p "$RASTER_DATA"
#mkdir -p "$SAT_DATA"
mkdir -p "$ELEV_DATA"   # ?? unused ??
mkdir -p "$VRT_DATA"



# disabled: $KML_DATA $SAT_DATA
for ITEM in $RASTER_DATA $ELEV_DATA $VRT_DATA ;  do
   chmod -R 775 "$ITEM"
   chgrp -R users "$ITEM"
done


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


mkdir -p "$QUICKSTART"/workspace
chmod g+w "$QUICKSTART"/workspace
chgrp users "$QUICKSTART"/workspace

chmod g+w /usr/local/share/ossim/elevation
chgrp users /usr/local/share/ossim/elevation


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


unset OSSIM_PREFS_FILE

cp -r "$APP_DATA_DIR"/* "$QUICKSTART"/
if [ -L "$USER_HOME/ossim" ] ; then
   rm -f "$USER_HOME"/ossim
fi
ln -s "$QUICKSTART" "$USER_HOME"/ossim
# does the above symlink need to be owned by $USER?
if [ -L /etc/skel/ossim ] ; then
   rm -f /etc/skel/ossim
fi
ln -s "$QUICKSTART" /etc/skel/ossim

for dir in "$QUICKSTART" "$RASTER_DATA" "$DATA_FOLDER" ; do
  chgrp -R users $dir
  chmod -R g+w $dir
done

chmod 644 /usr/local/share/ossim/*.pdf

#### cleanup
rm -rf "$QUICKSTART"/.svn


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
