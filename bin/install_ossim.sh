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
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_ossim
APP_DATA_DIR="$BUILD_DIR/../app-data/ossim"
DATA_FOLDER="/usr/local/share/data"
OSSIM_VERSION=1.8.16
BUILD_DATE=20140202

#CAUTION: UbuntuGIS should be enabled only through setup.sh
#Add repositories
#wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_7_9/sources.list.d/ubuntugis.list \
#     --output-document=/etc/apt/sources.list.d/ubuntugis.list

#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get -q update

apt-get install --assume-yes ossim-core libgdal1-1.10.0-grass

# install main dependencies
apt-get install --assume-yes libtiff4 libgeotiff2 \
  libfreetype6 libcurl3 libopenscenegraph80 libqt4-opengl \
  libexpat1 libpng3 libfftw3-3 libqt3-mt \
  libopenmpi1.3 libqt4-qt3support python-pip

# python-pandas python-netcdf spyder

apt-get install --assume-yes krb5-multidev libexpat-ocaml libfindlib-ocaml \
  libgnutls-openssl27 libopenjpeg2 libpodofo0.9.0 libpthread-stubs0 \
  libqt4-sql-sqlite libtiffxx0c2 ocaml-base-nox \
  ocaml-findlib ocaml-interp ocaml-nox pkg-config \
  libqt4-core

# for planetsasha:
# qt4-dev-tools qt4-linguist-tools qt4-qmake xorg-sgml-doctools


# fragile @ ubuntugis
#apt-get install --assume-yes libgdal1h  libgdal1-1.10.0-grass


## update for next release ##
# apt-get install --assume-yes python-dev  # python-mpltoolkits.basemap # 170 mb!!! 
# pip install --upgrade pandas
# pip install bottleneck
# pip install oct2py


if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   "$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
   exit 1
fi


#### download ossim
mkdir -p /tmp/build_ossim
cd /tmp/build_ossim

# OSSIM Qt apps built on live dvd
wget -c --progress=dot:mega \
  "http://download.osgeo.org/livedvd/data/ossim/ossim-qt_1.8.16.tar.gz"

tar -x -z --no-same-owner -C / -f ossim-qt_1.8.16.tar.gz

ldconfig

mkdir -p /usr/share/ossim/

wget -N --progress=dot:mega \
   "http://download.osgeo.org/livedvd/data/ossim/ossim_settings.tar.gz"

tar xzf ossim_settings.tar.gz

chown -R root.root ossim_settings/
#FIXME: "cannot move: Directory not empty"
mv ossim_settings/* /usr/share/ossim/


#patch for ticket https://trac.osgeo.org/osgeo/ticket/647 
sed -i -e 's/OsssimPlanet/OssimPlanet/g' /usr/share/ossim/ossimplanet.desktop

mv /usr/share/ossim/images/ossimPlanet.xpm /usr/share/pixmaps/ossimPlanet.xpm
mv /usr/share/ossim/images/ossim.xpm /usr/share/pixmaps/ossim.xpm

mv /usr/share/ossim/imagelinker.desktop /usr/share/applications/imagelinker.desktop
mv /usr/share/ossim/ossimplanet.desktop /usr/share/applications/ossimplanet.desktop

OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"
export OSSIM_PREFS_FILE

BRCFILE="/etc/skel/.bashrc"
echo 'export OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$BRCFILE"
echo 'export OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$USER_HOME/.bashrc"

apt-get install --assume-yes grass-core qgis python-pysqlite2 \
   python-scipy python-serial python-psycopg2 proj-bin python-lxml \
   libqt4-core python-distutils-extra python-setuptools \
   python-qscintilla2
   
   
cp /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/imagelinker.desktop"
sed -i -e 's/^Name=imagelinker/Name=Imagelinker/' \
   "$USER_HOME/Desktop/imagelinker.desktop"

cp /usr/share/applications/ossimplanet.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/ossimplanet.desktop"

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




#Install the Manual and Intro guide locally and link them to the description.html
mkdir -p /usr/local/share/ossim

wget --read-timeout=20 --tries=5 --progress=dot:mega \
     "http://download.osgeo.org/ossim/docs/pdfs/ossim_users_guide.pdf" \
     --output-document=/usr/local/share/ossim/ossim_users_guide.pdf

#echo "FIXME: doesn't exist ==>
# 'ln -s /usr/share/doc/ossim-doc/ossimPlanetUsers.pdf /usr/local/share/ossim/'"

# pdf temporary stored on my ftp, waiting to add it on ossim download page.   
wget --read-timeout=20 --tries=5 --progress=dot:mega \
     "http://download.osgeo.org/livedvd/data/ossim/OSSIM_Whitepaper.pdf" \
     --output-document=/usr/local/share/ossim/OSSIM_Whitepaper.pdf


#Download data used to test the application
KML_DATA="$DATA_FOLDER/kml"
RASTER_DATA="$DATA_FOLDER/raster"
ELEV_DATA=/usr/share/ossim/elevation/elev
SAT_DATA="$RASTER_DATA/cape_cod"
#echo "FIXME: does VRT data actually ship anymore?"
VRT_DATA="$DATA_FOLDER/vrt"
QUICKSTART=/usr/local/share/ossim/quickstart

mkdir -p "$KML_DATA"
mkdir -p "$RASTER_DATA"
#mkdir -p "$SAT_DATA"
mkdir -p "$ELEV_DATA"   # ?? unused ??
mkdir -p "$VRT_DATA"



# disabled: $VRT_DATA $KML_DATA $SAT_DATA
for ITEM in $RASTER_DATA $ELEV_DATA $VRT_DATA $KML_DATA ;  do
   chmod -R 775 "$ITEM"
   chgrp -R users "$ITEM"
done


# Cape Cod SRTM and LANDSAT
DATA_URL="http://download.osgeo.org/livedvd/data/ossim/"
BASENAME="p011r031_7t19990918_z19_nn"
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

wget -nv "$DATA_URL/ossim_preference" \
     --output-document=/usr/share/ossim/ossim_preference

apt-get --assume-yes install libjpeg62

OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference
export OSSIM_PREFS_FILE

if [ -e "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" ] ; then
 /usr/bin/ossim-img2rr \
    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"

 /usr/bin/ossim-create-histo \
    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"
fi


# it turns up there anyway?
#/usr/bin/gdal_translate -of VRT "$RASTER_DATA"/BlueMarble_small.tif \
#    /usr/share/ossim/images/reference/bluemarble.tif

ln -s /usr/share/ossim/images/reference/bluemarble.tif \
  /usr/local/share/data/raster/


mkdir -p "$QUICKSTART"/workspace
chmod g+w "$QUICKSTART"/workspace
chgrp users "$QUICKSTART"/workspace

chmod g+w /usr/share/ossim/elevation
chgrp users /usr/share/ossim/elevation


#### spearfish subset to VRT
GISBASE=/usr/lib/grass64
export GISBASE
SPEARFISH_RASTER="/usr/local/share/grass/spearfish60/PERMANENT/cellhd"

for MAP in "$SPEARFISH_RASTER"/* ; do
    gdal_translate -of VRT "$MAP" "$VRT_DATA/`basename $MAP`.vrt"
done

FILES=`ls "$VRT_DATA"/*.vrt`
/usr/bin/ossim-img2rr $FILES
/usr/bin/ossim-create-histo $FILES


/usr/bin/gdal_translate -of VRT \
    "$SPEARFISH_RASTER"/elevation.10m \
    "$QUICKSTART"/workspace/elevation10m.vrt

/usr/bin/gdal_translate -of GTIFF -ot Float64 \
    "$QUICKSTART"/workspace/elevation10m.vrt \
    "$QUICKSTART"/workspace/elevation10m.tif

OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference \
  /usr/bin/ossim-orthoigen -w general_raster_bip \
    "$QUICKSTART"/workspace/elevation10m.tif \
    /usr/share/ossim/elevation/spearfish/elevation10m.ras


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
