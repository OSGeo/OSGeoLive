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

#Add repositories

#wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
#     --output-document=/etc/apt/sources.list.d/ubuntugis.list

#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

#apt-get update
#apt-get install --assume-yes ossim-bin ossimplanet ossim-doc

#Install Karmic packages from ubuntugis
TMP="/tmp/build_ossim"
mkdir -p "$TMP"
cd "$TMP"  
for i in libossim_1.8.3-4_i386.deb ossim-bin_1.8.3-4_i386.deb ossim-doc_1.8.3-4_all.deb ossimplanet_1.8.3-4_i386.deb; do
  wget -c --progress=dot:mega https://launchpad.net/~ubuntugis/+archive/ubuntugis-unstable/+files/$i
  dpkg -i $i
done

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


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
  command="/usr/bin/imagelinker"\
  icon="/usr/share/pixmaps/ossim.xpm"
EOF
  update-menus
fi

if [ ! -e /usr/share/menu/ossimplanet ] ; then
   cat << EOF > /usr/share/menu/ossimplanet
?package(ossimplanet):needs="X11"\
  section="Applications/Science/Geoscience"\
  title="Ossimplanet"\
  command="/usr/bin/ossimplanet"\
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
mkdir /usr/local/share/ossim/ossim_data 
mkdir -p /usr/share/ossim/elevation/elev 
chmod -R 777 /usr/local/share/ossim/ossim_data 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band1.tif  --output-document=/usr/local/share/ossim/ossim_data/band1.tif           
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band2.tiff  --output-document=/usr/local/share/ossim/ossim_data/band2.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/band3.tiff  --output-document=/usr/local/share/ossim/ossim_data/band3.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/SRTM_u03_n041e002.tif  --output-document=/usr/local/share/ossim/ossim_data/SRTM_u03_n041e002.tif
wget -c --progress=dot:mega http://www.geofemengineering.it/data/kml/Plaza_de_Cataluna.kmz --output-document=/usr/local/share/ossim/ossim_data/Plaza_de_Cataluna.kmz
wget -c --progress=dot:mega http://www.geofemengineering.it/data/kml/View_towards_Sagrada_Familia.kmz --output-document=/usr/local/share/ossim/ossim_data/View_towards_Sagrada_Familia.kmz
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/landsatrgb.prj --output-document=/usr/local/share/ossim/ossim_data/landsatrgb.prj
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/session.session --output-document=/usr/local/share/ossim/ossim_data/session.session
 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N40E002.hgt --output-document=/usr/share/ossim/elevation/elev/N40E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N40E002.omd --output-document=/usr/share/ossim/elevation/elev/N40E002.omd 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N41E002.hgt --output-document=/usr/share/ossim/elevation/elev/N41E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N41E002.omd --output-document=/usr/share/ossim/elevation/elev/N41E002.omd  
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N42E002.hgt --output-document=/usr/share/ossim/elevation/elev/N42E002.hgt 
wget -c --progress=dot:mega http://www.geofemengineering.it/data/ossim_data/elev/N42E002.omd --output-document=/usr/share/ossim/elevation/elev/N42E002.omd 
ossim-img2rr /usr/local/share/ossim/ossim_data/band1.tif /usr/local/share/ossim/ossim_data/band2.tif /usr/local/share/ossim/ossim_data/band3.tif
chmod 644 /usr/local/share/ossim/*.pdf

echo "Finished installing Ossim "
