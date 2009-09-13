#!/bin/sh
# Installation of MapTiler application
#
# In case anything fails please contact: Klokan Petr Pridal <klokan@klokan.cz>
#
# Should be run after the ./install_grass.sh - it is dependent on the same repository:
# See: http://les-ejk.cz/2009/05/grass-64-rc4-for-ubuntu-904/
# Alternativelly ./install_qgis is adding ubuntugis repository, which also contains GDAL 1.6

TMP=/tmp/maptiler_downloads
MAPTILERDEB="maptiler_1.0.beta1_all.deb"

cd $TMP

# Test if the repository with gdal 1.6 is available 

if [ ! -n "`grep ubuntugis /etc/apt/sources.list`" ] ; then
  if [ ! -n "`grep les-ejk /etc/apt/sources.list`" ] ; then
    echo "Apt is missing the GDAL 1.6 repository: this is added either by GRASS installation script or by QGIS."
    exit 1
  fi
fi

# Install dependencies

PACKAGES="python python-wxgtk2.8 python-gdal"

TO_INSTALL=""

for PACKAGE in $PACKAGES ; do
  if [ `dpkg -l $PACKAGE | grep -c '^ii'` -eq 0 ] ; then
    TO_INSTALL="$TO_INSTALL $PACKAGE"
  fi
done

if [ -n "$TO_INSTALL" ] ; then
  echo "Installing: $TO_INSTALL"
  apt-get --assume-yes install $TO_INSTALL

  if [ $? -ne 0 ] ; then
    echo "ERROR: package install failed"
    exit 1
  fi 
fi

# If MapTiler is not installed then download the .deb package and install it
if [ `dpkg -l maptiler | grep -c '^ii'` -eq 0 ] ; then
  wget -c http://maptiler.googlecode.com/files/$MAPTILERDEB
  dpkg -i $MAPTILERDEB
  rm $MAPTILERDEB
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

