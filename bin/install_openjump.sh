#!/bin/sh
 
## Setup things... ##
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir /tmp/openjump_downloads
cd /tmp/openjump_downloads


## Install Application ##

# get openjump
if [ -f "openjump-v1.3.zip" ]
then
   echo "openjump-v1.3.zip has already been downloaded."
else
   wget http://sourceforge.net/projects/jump-pilot/files/OpenJUMP/1.3/openjump-v1.3.zip/download
fi
# unpack it and copy it to /usr/lib
unzip openjump-v1.3.zip -d /usr/lib


## Configure Application ##

# create link to startup script
ln -s /usr/lib/openjump-1.3/bin/openjump.sh /usr/bin/openjump

# Download desktop icon
if [ -f "openjump.icon" ]
then
   echo "openjump.icon has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/openjump-conf/openjump.ico
fi
# copy it into the udig folder
cp openjump.ico /usr/lib/openjump-1.3

# Download desktop link
if [ -f "openjump.desktop" ]
then
   echo "openjump.desktop has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/openjump-conf/openjump.desktop
fi
# copy it into the udig folder
cp openjump.desktop $HOME/Desktop


## Sample Data ##

# Download udig's sample data
if [ -f "ogrs2009_tutorialddata_mod.zip" ]
then
   echo "ogrs2009_tutorialddata_mod.zip has already been downloaded."
else
   wget http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.3%20Docs%20%28English%29/ogrs2009_tutorialddata_mod.zip/download
fi
#unzip the file into /usr/local/share/udig-data
mkdir /usr/local/share/openjump-data
unzip ogrs2009_tutorialddata_mod.zip -d /usr/local/share/openjump-data


## Documentation ##

# Download udig's documentation
if [ -f "ogrs2009_tutorial.pdf" ]
then
   echo "ogrs2009_tutorial.pdf has already been downloaded."
else
   wget http://sourceforge.net/projects/jump-pilot/files/Documentation/OpenJUMP%201.3%20Docs%20%28English%29/ogrs2009_tutorial.pdf/download
fi

#copy into /usr/local/share/udig-docs
mkdir /usr/local/share/openjump-docs
cp ogrs2009_tutorial.pdf /usr/local/share/openjump-docs
