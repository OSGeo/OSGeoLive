#!/bin/bash
#############################################################################
#
# Purpose: This script will install i3geo
#
#############################################################################
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation.
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
#
#############################################################################

# Requires: apache2 php5 libapache2-mod-php5 cgi-mapserver mapserver-bin
#      php-mapscript php5-gd php5-sqlite gfortran r-base r-base-core
#      r-base-sp r-cran-maptools
#
# Uninstall:
# ============
# sudo rm -rf /var/www/html/i3geo
# sudo rm -rf /var/www/html/ms_tmp
# sudo rm -rf /tmp/ms_tmp

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


#OSGEO live username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

#Repository url
I3GEO_DOWNLOAD_URL="http://svn.gvsig.org/svn/i3geo/arquivos_versoes/v46"

#Filename
I3GEO_COMPRESSED_FILE="livedvdosgeo_i3geo46_26_dezembro_2012.zip"

#i3GEO dependencies
I3GEO_DEPENDENCIES=(apache2 php5 libapache2-mod-php5 cgi-mapserver mapserver-bin php-mapscript php5-gd php5-sqlite)
R_DEPENDENCIES=(r-cran-maptools)

#Installation variables
ROOT_DIR="/var/www/html"
TMP_DIR="/tmp"
LOCAPLIC="$ROOT_DIR/i3geo"


#Temporary directory, symbolic link to temporary directory
mkdir "$TMP_DIR/ms_tmp"
ln -s "$TMP_DIR/ms_tmp" "$ROOT_DIR/ms_tmp"
#Temporary directory permissions
chown -R www-data:www-data "$TMP_DIR/ms_tmp"
chown -R www-data:www-data "$ROOT_DIR/ms_tmp"
chmod -R 755 "$TMP_DIR/ms_tmp"
chmod -R 755 "$ROOT_DIR/ms_tmp"    

#Deploy i3geo
cd "$TMP_DIR"
wget -c --progress=dot:mega "$I3GEO_DOWNLOAD_URL/$I3GEO_COMPRESSED_FILE"
echo -n "Extracting i3geo in temp directory"
unzip -q "$I3GEO_COMPRESSED_FILE" -d "$ROOT_DIR"/
echo -n "Done"
rm "$I3GEO_COMPRESSED_FILE"

#Change permissions
cd "$ROOT_DIR"
chown -R www-data i3geo/
chgrp -R www-data i3geo/
chmod -R 755 i3geo/


#add R repository to have the latest version of R
#cd /etc/apt/
#echo "deb http://cran.es.r-project.org/bin/linux/debian squeeze-cran/" >> sources.list
#apt-key adv --keyserver subkeys.pgp.net --recv-key 381BA480
#apt-get update

#Install i3geo dependencies
for i in "${I3GEO_DEPENDENCIES[@]}"; do
  IS_INSTALLED=$(dpkg --get-selections | grep -w $i | grep -w install)
  if [ -z "$IS_INSTALLED" ]; then
    echo "Package $i is not installed"
    echo "Installing $i ..."
    apt-get -y install "$i"
  else
    echo "$i package is allready installed"
  fi
done

#Install R and dependencies
echo "Installing R"
for i in "${R_DEPENDENCIES[@]}"; do
  IS_INSTALLED=$(dpkg --get-selections | grep -w $i | grep -w install)
  if [ -z "$IS_INSTALLED" ]; then
    echo "Package $i is not installed"
    echo "Installing $i ..."
    apt-get -y install "$i"
  else
    echo "$i package is allready installed"
    # ==> why the reinstall? this isn't Windows.
    apt-get --reinstall install "$i"
  fi
done

# get R libraries
echo "Downloading R required libraries"
cd "$TMP_DIR"
wget http://cran.r-project.org/src/contrib/gpclib_1.5-3.tar.gz
wget http://cran.r-project.org/src/contrib/deldir_0.0-21.tar.gz	
wget http://cran.r-project.org/src/contrib/spatstat_1.30-0.tar.gz

# install R libraries
echo "Installing R required libraries"
R CMD INSTALL gpclib_1.5-3.tar.gz
R CMD INSTALL deldir_0.0-21.tar.gz
R CMD INSTALL spatstat_1.30-0.tar.gz

#Cleaning temp files
rm gpclib_1.5-3.tar.gz
rm deldir_0.0-21.tar.gz
rm spatstat_1.30-0.tar.gz

# Reload Apache
/etc/init.d/apache2 force-reload

### install desktop icon ##
echo "Installing i3geo desktop icon"
if [ ! -e "/usr/local/share/icons/i3geo1.png" ] ; then
   mkdir -p /usr/local/share/icons
   cp "$ROOT_DIR"/i3geo/imagens/i3geo1.png /usr/local/share/icons/
fi

#Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/i3geo.desktop ] ; then
   mkdir -p /usr/local/share/applications
   cat << EOF > /usr/local/share/applications/i3geo.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=i3geo
Comment=i3geo
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/i3geo/ms_criamapa.php?idioma=en
Icon=/usr/local/share/icons/i3geo1.png
Terminal=false
StartupNotify=false
EOF
fi

# Add lanuncher into the Desktop folder
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop/"
# Add desktop icon
if [ -d "$USER_DESKTOP" ] ; then
   echo "Copying icon to desktop at $USER_DESKTOP"
   cp /usr/local/share/applications/i3geo.desktop "$USER_DESKTOP/i3geo.desktop"
   chown $USER_NAME:$USER_NAME "$USER_DESKTOP/i3geo.desktop"
   chmod +x "$USER_DESKTOP/i3geo.desktop"
fi

# Fix path to natural_earth
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/aplicmap/geral1debianv6.map
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/aplicmap/estadosldebian.map 
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/aplicmap/estadosl.map 
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/temas/states_provinces.map
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/temas/populated_places_simple.map
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/temas/geography_regions_polys.map
#sed -i -e 's/natural_earth/natural_earth2/' "$ROOT_DIR"/i3geo/temas/estadosl.map


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
