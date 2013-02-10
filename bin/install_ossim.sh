#!/bin/sh
#
# install_ossim.sh
#
#
# Created by Massimo Di Stefano on 07/12/09.
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL >= 2.1.

echo "==============================================================="
echo "install_ossim.sh"
echo "==============================================================="

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR=/tmp/build_ossim
BUILD_DIR=`pwd`
APP_DATA_DIR="$BUILD_DIR/../app-data/ossim"
DATA_FOLDER="/usr/local/share/data"
#OSSIM_VERSION=1.8.12
#BUILD_DATE=20110704


#Add repositories

wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get -q update

#temp solution
#apt-get install --assume-yes ossim-core

# install main dependencies
apt-get install --assume-yes libtiff4 libgeotiff2 libgdal1-1.9.0 \
  libfreetype6 libcurl3 libopenscenegraph80 libqt4-opengl \
  libexpat1 libpng3 libgdal1-1.9.0-grass libfftw3-3 libqt3-mt \
  libopenmpi1.3 libqt4-qt3support ipython-notebook

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


#### download ossim
mkdir -p /tmp/build_ossim
cd /tmp/build_ossim


wget -N --progress=dot:mega "http://epi.whoi.edu/osgeolive/ossim.tar.gz" 
tar -zxf ossim.tar.gz
# running tar as root expands as the UID on the host machine that made it, so
chown -R root.root ossim/
mv ossim /usr/local/
# is /usr/local/ossim/ actually needed in the lib search path?
echo "/usr/local/ossim/
/usr/local/ossim/lib/" >> ossim.conf
mv ossim.conf /etc/ld.so.conf.d/
ldconfig

mkdir /usr/share/ossim/
wget -N --progress=dot:mega http://epi.whoi.edu/osgeolive/ossim_settings.tar.gz 
tar -zxf ossim_settings.tar.gz
chown -R root.root ossim_settings/
mv ossim_settings/* /usr/share/ossim/

#patch for ticket https://trac.osgeo.org/osgeo/ticket/647 
sed -i -e 's/OsssimPlanet/OssimPlanet/g' /usr/share/ossim/ossimplanet.desktop

mv /usr/share/ossim/images/ossimPlanet.xpm /usr/share/pixmaps/ossimPlanet.xpm
mv /usr/share/ossim/images/ossim.xpm /usr/share/pixmaps/ossim.xpm
mv /usr/share/ossim/imagelinker.desktop /usr/share/applications/imagelinker.desktop
mv /usr/share/ossim/ossimplanet.desktop /usr/share/applications/ossimplanet.desktop

if [ `grep -c '/usr/local/ossim/bin' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   echo 'PATH="$PATH:/usr/local/ossim/bin"' >> "$USER_HOME/.bashrc"
   echo "export PATH" >> "$USER_HOME/.bashrc"
   echo 'OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$USER_HOME/.bashrc"
   echo "export OSSIM_PREFS_FILE" >> "$USER_HOME/.bashrc"
   #source "$USER_HOME/.bashrc"
fi

BRCFILE="/etc/skel/.bashrc"
if [ `grep -c '/usr/local/ossim/bin' "$BRCFILE"` -eq 0 ] ; then
   # we know that it is safe to use bashisms in .BASHrc
   echo 'export PATH="$PATH:/usr/local/ossim/bin"' >> "$BRCFILE"
   echo 'export OSSIM_PREFS_FILE="/usr/share/ossim/ossim_preference"' >> "$BRCFILE"
fi


# Additional dependence for Grass / Qgis plug-in :
#

apt-get install --assume-yes grass-core qgis python-pysqlite2 python-pygame \
   python-scipy python-serial python-psycopg2 proj-bin python-lxml \
   libqt4-core python-distutils-extra python-setuptools python-qscintilla2 
   # spyder



#### PlanetSasha commented for now
#mkdir $USER_HOME/Desktop/PlanetSasha
#FIXME: Please do not use "chmod 777". Add to the "users" group and chmod g+w instead.
#chmod -R 777 $USER_HOME/Desktop/PlanetSasha
#
#FIXME: do not checkout directly to $USER_HOME. Use "svn export" to /usr/local/share/data/
#  instead, or svn co to /tmp/build_ossim/ then copy dir to /usr/local/share/data/ and
#  symlink into $HOME.
#svn co http://svn.osgeo.org/ossim/trunk/gsoc/PlanetSasha $USER_HOME/Desktop/PlanetSasha
#FIXME: Do not use chmod 777. see above.
#chmod -R 777 $USER_HOME/Desktop/PlanetSasha
#
#cp $USER_HOME/Desktop/PlanetSasha/grass_script/r.planet.py /usr/lib/grass64/scripts/
#cp $USER_HOME/Desktop/PlanetSasha/grass_script/v.planet.py /usr/lib/grass64/scripts/
#cp $USER_HOME/Desktop/PlanetSasha/grass_script/ogrTovrt.py /usr/lib/grass64/scripts/
#cp $USER_HOME/Desktop/PlanetSasha/grass_script/d.png.legend /usr/lib/grass64/scripts/
#
#FIXME: python-sphinx package needs to be installed first?
#
#hg clone https://spyderlib.googlecode.com/hg/ spyderlib
#cd spyderlib
#python setup.py install
#cd ..
#rm -rf spyderlib
####



cp /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/imagelinker.desktop"
sed -i -e 's/^Name=imagelinker/Name=Imagelinker/' "$USER_HOME/Desktop/imagelinker.desktop"

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
mkdir /usr/local/share/ossim

wget --progress=dot:mega "http://download.osgeo.org/ossim/docs/pdfs/ossim_users_guide.pdf" \
     --output-document=/usr/local/share/ossim/ossim_users_guide.pdf

#echo "FIXME: doesn't exist ==> 'ln -s /usr/share/doc/ossim-doc/ossimPlanetUsers.pdf /usr/local/share/ossim/'"

# pdf temporary stored on my ftp, waiting to add it on ossim download page.   
wget --progress=dot:mega "http://www.geofemengineering.it/data/OSSIM_Whitepaper.pdf" \
     --output-document=/usr/local/share/ossim/OSSIM_Whitepaper.pdf


#Download data used to test the application
#KML_DATA="$DATA_FOLDER/kml"
RASTER_DATA="$DATA_FOLDER/raster"
ELEV_DATA=/usr/share/ossim/elevation/elev
SAT_DATA="$RASTER_DATA/cape_cod"
#echo "FIXME: does VRT data actually ship anymore?"
VRT_DATA="$DATA_FOLDER/vrt"
QUICKSTART=/usr/local/share/ossim/quickstart

#mkdir -p "$KML_DATA"
mkdir -p "$RASTER_DATA"
mkdir -p "$SAT_DATA"
mkdir -p "$ELEV_DATA"   # ?? unused ??
#mkdir -p "$VRT_DATA"



# disabled: $VRT_DATA $KML_DATA
for ITEM in $RASTER_DATA $ELEV_DATA $SAT_DATA ;  do
   chmod -R 775 "$ITEM"
   chgrp -R users "$ITEM"
done

# Cape Cod SRTM and LANDSAT
DATA_URL="http://epi.whoi.edu/osgeolive/"
BASENAME="p011r031_7t19990918_z19_nn"
for BAND in 10 20 30 ; do
    # LANDSAT
    wget --progress=dot:mega "$DATA_URL/ossim_data/${BASENAME}$BAND.tif" \
         --output-document="$SAT_DATA/${BASENAME}$BAND.tif"
    ls -l "$SAT_DATA/${BASENAME}$BAND.tif"
    chmod a-x "$SAT_DATA/${BASENAME}$BAND.tif"
done

# SRTM
wget --progress=dot:mega "$DATA_URL/ossim_data/SRTM_fB03_p011r031.tif"  \
     --output-document="$SAT_DATA/SRTM_fB03_p011r031.tif"
chmod a-x "$SAT_DATA/SRTM_fB03_p011r031.tif"

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

wget --progress=dot:mega "$DATA_URL/ossim_preference" \
     --output-document=/usr/share/ossim/ossim_preference


#### Updated North Carolina KML
wget -N --progress=dot:mega $DATA_URL/ossim_data/kml.tar.gz
tar -zxvf kml.tar.gz
chown -R root.root kml/
mv kml/* "$DATA_FOLDER"/north_carolina/kml/
rm -rf kml/


apt-get --assume-yes install libjpeg62

OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference
export OSSIM_PREFS_FILE

/usr/local/ossim/bin/ossim-img2rr \
    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"

/usr/local/ossim/bin/ossim-create-histo \
    "$SAT_DATA/p011r031_7t19990918_z19_nn10.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn20.tif" \
    "$SAT_DATA/p011r031_7t19990918_z19_nn30.tif"

/usr/bin/gdal_translate -of VRT "$RASTER_DATA"/BlueMarble_small.tiff \
    /usr/share/ossim/images/reference/bluemarble.tif

/usr/local/ossim/bin/ossim-img2rr \
   /usr/share/ossim/images/reference/bluemarble.tif
/usr/local/ossim/bin/ossim-create-histo \
   /usr/share/ossim/images/reference/bluemarble.tif

# replace 32bit Landsat files with 8bit versions
DATA_DIR="$DATA_FOLDER/north_carolina/rast_geotiff"

for BAND in 10 20 30 40 50 61 62 70 80 ; do
   BASENAME="lsat7_2002_$BAND.tif"
   NEWNAME="lsat7_2002_${BAND}_8bit.tif"

   /usr/bin/gdal_translate -ot Byte "$DATA_DIR/$BASENAME" "$DATA_DIR/$NEWNAME"
   rm "$DATA_DIR/$BASENAME"
   mv "$DATA_DIR/$NEWNAME" "$DATA_DIR/$BASENAME"

   /usr/local/ossim/bin/ossim-img2rr "$DATA_DIR/$BASENAME"
   /usr/local/ossim/bin/ossim-create-histo "$DATA_DIR/$BASENAME"
done

/usr/local/ossim/bin/ossim-orthoigen --writer general_raster_bip \
   "$DATA_DIR/elevation.tif" \
   /usr/share/ossim/elevation/nc/elevation.ras

/usr/local/ossim/bin/ossim-orthoigen --writer general_raster_bip \
   "$DATA_DIR/elev_lid792_1m.tif" \
   /usr/share/ossim/elevation/lidar/elev_lid792_1m.ras

unset OSSIM_PREFS_FILE


mkdir -p "$QUICKSTART"/workspace
chmod g+w "$QUICKSTART"/workspace
chgrp users "$QUICKSTART"/workspace

chmod g+w /usr/share/ossim/elevation
chgrp users /usr/share/ossim/elevation


#### spearfish subset to VRT
SPEARFISH_RASTER=/usr/local/share/grass/spearfish60/PERMANENT/cellhd/

#for i in $SPEARFISH_RASTER; do
#    gdal_translate -of VRT $SPEARFISH_RASTER/$i /home/user/data/workspace/$i.vrt

/usr/bin/gdal_translate -of VRT \
    "$SPEARFISH_RASTER"/elevation.10m \
    "$QUICKSTART"/workspace/elevation10m.vrt

/usr/bin/gdal_translate -of GTIFF -ot Float64 \
    "$QUICKSTART"/workspace/elevation10m.vrt \
    "$QUICKSTART"/workspace/elevation10m.tif

OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference \
  /usr/local/ossim/bin/ossim-orthoigen -w general_raster_bip \
    "$QUICKSTART"/workspace/elevation10m.tif \
    /usr/share/ossim/elevation/spearfish/elevation10m.ras

rm -f "$QUICKSTART"/workspace/elevation10m.tif

/usr/bin/gdal_translate -of VRT "$SPEARFISH_RASTER"/geology \
    "$QUICKSTART"/workspace/geology.vrt


#COORDS="N40E002 N41E002 N42E002"
# ? N40 is corrupt and N42 is all zeros ?
#COORDS=" N41E002 "
#for COORD in $COORDS ; do
#   wget --progress=dot:mega "$DATA_URL/ossim_data/elev/$COORD.hgt" \
#        --output-document="/usr/share/ossim/elevation/elev/$COORD.hgt"
#   wget --progress=dot:mega "$DATA_URL/ossim_data/elev/$COORD.omd" \
#        --output-document="/usr/share/ossim/elevation/elev/$COORD.omd"
#done


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


##### Setup custom IPython profile
## doesn't work!  sudo -u "$USER_NAME" \
ipython profile create osgeolive
mkdir -p "$USER_HOME"/.config/
mv /root/.ipython "$USER_HOME"/.config/ipython
sed -i -e "s|root|$USER_NAME|" "$USER_HOME"/.config/ipython/profile_osgeolive/*.py

mkdir -p /etc/skel/.config
cp -r "$USER_HOME"/.config/ipython /etc/skel/.config

IPY_CONF="$USER_HOME/.config/ipython/profile_osgeolive/ipython_notebook_config.py"
echo "c.NotebookApp.open_browser = False" >> "$IPY_CONF"
echo "c.NotebookApp.port = 12345"         >> "$IPY_CONF"
echo "c.NotebookManager.save_script=True" >> "$IPY_CONF"

cp "$IPY_CONF" /etc/skel/.config/ipython/profile_osgeolive/
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/.config


#### cleanup
rm -rf "$QUICKSTART"/.svn

echo "Finished installing Ossim"
