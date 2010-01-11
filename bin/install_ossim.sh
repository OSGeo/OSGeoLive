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

wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get update
apt-get install ossim-bin ossimplanet

# Additional dependence for Grass / Qgis plug-in :
#
apt-get install grass qgis python-pysqlite2 python-pygame python-scipy python-serial python-psycopg2


cat << EOF > /usr/share/applications/imagelinker.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Imagelinker
Comment=Imagelinker
Categories=Application;Education;Geography;
Exec=/usr/bin/imagelinker %F
Icon=/usr/share/pixmaps/ossim.xpm
Terminal=false
StartupNotify=false
Categories=Education;Geography;Qt;
MimeType=application/x-qgis-project;image/tiff;image/jpeg;image/jp2;application/x-raster-aig;application/x-mapinfo-mif;application/x-esri-shape;
EOF

cat << EOF > /usr/share/applications/ossimplanet.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Ossimplanet
Comment=Ossimplanet
Categories=Application;Education;Geography;
Exec=/usr/bin/ossimplanet %F
Icon=/usr/share/pixmaps/ossimPlanet.xpm
Terminal=false
StartupNotify=false
Categories=Education;Geography;Qt;
MimeType=application/x-qgis-project;image/tiff;image/jpeg;image/jp2;application/x-raster-aig;application/x-mapinfo-mif;application/x-esri-shape;
EOF

cp /usr/share/applications/imagelinker.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/imagelinker.desktop"
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
wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/ossimPlanetUsers.pdf \
	--output-document=/usr/local/share/ossim/ossimPlanetUsers.pdf
wget -c --progress=dot:mega http://download.osgeo.org/ossim/docs/pdfs/ossim_users_guide.pdf \
	--output-document=/usr/local/share/ossim/ossim_users_guide.pdf

chmod 644 /usr/local/share/ossim/*.pdf

echo "Finished installing Ossim "
