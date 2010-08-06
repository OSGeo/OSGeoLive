#!/bin/sh
#
# install_ossim.sh
# 
#
# Created by Massimo Di Stefano on 07/12/09.
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.


USER_NAME="user"
USER_HOME="/home/$USER_NAME"
BUILD_DIR=`pwd`
APP_DATA_DIR="$BUILD_DIR/../app-data/ossim"
DATA_FOLDER="/usr/local/share/data"

#Add repositories

#wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
#     --output-document=/etc/apt/sources.list.d/ubuntugis.list

#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160


# install main dependencies

sudo apt-get install --assume-yes libtiff4 libgeotiff1.2 libgdal1-1.7.0 \
libfreetype6 libcurl3 libopenscenegraph56 libqt4-opengl \
libexpat1 libpng3 libgdal1-1.7.0-grass libfftw3-3 libqt3-mt


# download ossim

cd /tmp
wget http://www.geofemengineering.it/data/ossim.tar.gz
tar -zxvf ossim.tar.gz
mv ossim /usr/local/
echo "/usr/local/ossim/
/usr/local/ossim/lib" >> ossim.conf
mv ossim.conf /etc/ld.so.conf.d/
ldconfig


wget http://www.geofemengineering.it/data/ossim_settings.tar.gz
tar -zxvf ossim_settings.tar.gz
mv ossim_settings ossim
mv ossim /usr/share/ossim

mv /usr/share/ossim/images/ossimPlanet.xpm /usr/share/pixmaps/ossimPlanet.xpm
mv /usr/share/ossim/images/ossim.xpm /usr/share/pixmaps/ossim.xpm
mv /usr/share/ossim/imagelinker.desktop /usr/share/applications/imagelinker.desktop
mv /usr/share/ossim/ossimplanet.desktop /usr/share/applications/ossimplanet.desktop


echo "PATH=$PATH:/usr/local/ossim:/usr/local/ossim/bin" >> /home/user/.bashrc
echo "export PATH" >> /home/user/.bashrc
# source /home/user/.bashrc


# Additional dependence for Grass / Qgis plug-in :
#
apt-get install --assume-yes grass qgis python-pysqlite2 python-pygame python-scipy \
   python-serial python-psycopg2




cp /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/imagelinker.desktop"
sed -i -e 's/^Name=imagelinker/Name=Imagelinker/' "$USER_HOME/Desktop/imagelinker.desktop"

cp /usr/share/applications/ossimplanet.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/ossimplanet.desktop"

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
  command="/usr/local/ossim/ossimplanet"\
  icon="/usr/share/pixmaps/ossimPlanet.xpm"
EOF
  update-menus
fi



#Install the Manual and Intro guide locally and link them to the description.html
mkdir /usr/local/share/ossim
wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/ossim_users_guide.pdf \
	--output-document=/usr/local/share/ossim/ossim_users_guide.pdf
ln -s /usr/share/doc/ossim-doc/ossimPlanetUsers.pdf /usr/local/share/ossim/

wget -c --progress=dot:mega http://ossim.telascience.org/ossimdata/Documentation/OSSIM_Whitepaper.pdf \
        --output-document=/usr/local/share/ossim/OSSIM_Whitepaper.pdf


#Download data used to test the application
KML_DATA=$DATA_FOLDER/kml
RASTER_DATA=$DATA_FOLDER/raster
ELEV_DATA=/usr/share/ossim/elevation/elev
QUICKSTART=/usr/local/share/ossim/quickstart
mkdir -p $KML_DATA
mkdir -p $RASTER_DATA
mkdir -p $ELEV_DATA

wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band1.tif  --output-document=$RASTER_DATA/band1.tif           
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band2.tiff  --output-document=$RASTER_DATA/band2.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band3.tiff  --output-document=$RASTER_DATA/band3.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/SRTM_u03_n041e002.tif  --output-document=$RASTER_DATA/SRTM_u03_n041e002.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/kml/Plaza_de_Cataluna.kmz --output-document=$KML_DATA/Plaza_de_Cataluna.kmz
wget -c --progress=dot:mega http://www.geofemengineering.it/data/kml/View_towards_Sagrada_Familia.kmz --output-document=$KML_DATA/View_towards_Sagrada_Familia.kmz
#wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/landsatrgb.prj --output-document=$PKG_DATA/landsatrgb.prj
#wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/session.session --output-document=$PKG_DATA/session.session
ossim-img2rr $RASTER_DATA/band1.tif $RASTER_DATA/band2.tif $RASTER_DATA/band3.tif
 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N40E002.hgt --output-document=/usr/share/ossim/elevation/elev/N40E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N40E002.omd --output-document=/usr/share/ossim/elevation/elev/N40E002.omd 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N41E002.hgt --output-document=/usr/share/ossim/elevation/elev/N41E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N41E002.omd --output-document=/usr/share/ossim/elevation/elev/N41E002.omd  
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N42E002.hgt --output-document=/usr/share/ossim/elevation/elev/N42E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N42E002.omd --output-document=/usr/share/ossim/elevation/elev/N42E002.omd 

cp -r $APP_DATA_DIR $QUICKSTART
ln -s $QUICKSTART $USER_HOME/ossim

for dir in $QUICKSTART $KML_DATA $RASTER_DATA; do
  chgrp -R users $dir
  chmod -R g+w $dir
done

chmod 644 /usr/local/share/ossim/*.pdf

echo "Finished installing Ossim "
