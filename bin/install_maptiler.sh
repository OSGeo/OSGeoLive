#!/bin/sh
# Installation of MapTiler application
#
# In case anything fails please contact: Klokan Petr Pridal <klokan@klokan.cz>
#
# UbuntuGIS repository added to the Apt (same like in QGIS and GRASS)
# Hack to start with python2.5

TMP="/tmp/build_maptiler"
MAPTILERDEB="maptiler_1.0.beta2_all.deb"

#Can't cd to a directory before you make it, may be uneeded now
mkdir "$TMP"
#cd "$TMP"

#Add repositories
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
   --output-document=/etc/apt/sources.list.d/ubuntugis.list

#Add signed key for repositorys LTS and non-LTS
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  
apt-get update


# Install dependencies
PACKAGES="python python-wxgtk2.8 python-gdal"

echo "Installing: $PACKAGES"
apt-get --assume-yes install $PACKAGES
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed"
   exit 1
fi


# If MapTiler is not installed then download the .deb package and install it
if [ `dpkg -l maptiler | grep -c '^ii'` -eq 0 ] ; then
  wget -c "http://maptiler.googlecode.com/files/$MAPTILERDEB" --output-document="${TMP}/${MAPTILERDEB}"
  dpkg -i "${TMP}/${MAPTILERDEB}"
  #rm "$MAPTILERDEB"
fi

# Test if installation was correct and create the Desktop icon
if [ -e /usr/share/applications/maptiler.desktop ] ; then
  cp /usr/share/applications/maptiler.desktop ~user/Desktop/
  chown user:user ~user/Desktop/maptiler.desktop
else
  echo "ERROR: Installation of the MapTiler failed."
  exit 1
fi

# Everything is OK
echo "MapTiler is installed"
echo "---------------------"
echo "To try it you should:"
echo ""
echo " 1. Start MapTiler by clicking the icon on the Desktop"
echo " 2. Load in the second step example raster GEODATA (with georerence/srs)"
echo " 3. Go trough all the steps with 'Next' up to the Render"
echo " 4. Once the render is finished you can click in the GUI to open a folder with tiles. When you open googlemaps.html or openlayers.html then you see your geodata warped to the overlay of popular interactive web maps as Google Maps."
echo ""
echo "The map tiles are displayed directly from your disk. To publish the map to Internet just upload the folder with tiles to any webserver or Amazon S3" 

