#!/bin/sh
# script to install GRASS GIS
#    written by H.Bowman <hamish_b  yahoo com>
#  homepage: http://grass.osgeo.org/

# this does not attempt to install QGIS-plugin infrastructure, that should
# be done in another script.


PACKAGES="grass grass-doc avce00 e00compr gdal-bin gpsbabel more"

MINIMUM_VERSION=6.4

TO_INSTALL=""
for PACKAGE in $PACKAGES ; do
   if [ `dpkg -l $PACKAGE | grep -c '^ii'` -eq 0 ] ; then
      TO_INSTALL="$TO_INSTALL $PACKAGE"
   fi
done

if [ -n "$TO_INSTALL" ] ; then
   apt-get --assume-yes install $TO_INSTALL

   if [ $? -ne 0 ] ; then
      echo "ERROR: package install failed: $TO_INSTALL"
      #exit 1
   fi
fi

if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install either first" 
   exit 1
fi

GRASS_VERSION=`dpkg -s grass | grep 'Version' | awk '{print $2}' | cut -f1,2 -d.`
if [ `echo "$GRASS_VERSION $MINIMUM_VERSION" | awk '{if ($1 < $2) {print 1} else {print 0} }'` -eq 1 ] ; then
   echo "WARNING: Installed version ($GRASS_VERSION) is older than the recommended version ($MINIMUM_VERSION)."
   echo "         Please fix!"
   #exit 1
fi


# get sample data
mkdir -p /tmp/grass_downlaods
cd /tmp/grass_downlaods

# Spearfish dataset, 20mb .tgz
wget -nv http://grass.osgeo.org/sampledata/spearfish_grass60data-0.3.tar.gz
# North Carolina dataset, 135mb .tgz
wget -nv http://grass.osgeo.org/sampledata/nc_spm_latest.tar.gz


mkdir ~/grassdata
cd ~/grassdata/

tar xzf /tmp/grass_downlaods/spearfish_grass60data-0.3.tar.gz   
tar xzf /tmp/grass_downlaods/nc_spm_latest.tar.gz

if [ $? -eq 0 ] ; then
   rm -rf /tmp/grass_downlaods/
fi

# check that $HOME is appropriate to final system!
cat << EOF > ~/.grassrc6
LOCATION_NAME: spearfish60
MAPSET: user1
DIGITIZER: none
GISDBASE: $HOME/grassdata
DEBUG: 0
GRASS_GUI: wxpython
EOF


# setup startup stuff
mkdir ~/grassdata/addons
cat << EOF >> ~/.bashrc

GRASS_PAGER=more
GRASS_ADDON_PATH=~/grassdata/addons
export GRASS_PAGER GRASS_ADDON_PATH

EOF

echo "Done installing GRASS."
