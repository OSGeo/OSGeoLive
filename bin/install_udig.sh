#!/bin/sh
 
## Setup things... ##
 
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi
# create tmp folders
mkdir /tmp/udig_downloads
cd /tmp/udig_downloads


## Install Application ##

# get udig
if [ -f "udig-1.2-M6.linux.gtk.x86.tar.gz" ]
then
   echo "udig-1.2-M6.linux.gtk.x86.tar.gz has already been downloaded."
else
   wget http://udig.refractions.net/files/downloads/branches/udig-1.2-M6.linux.gtk.x86.tar.gz
fi
# unpack it and copy it to /usr/lib
tar -xzf udig-1.2-M6.linux.gtk.x86.tar.gz -C /usr/lib


## Configure Application ##

# Download modified startup script for udig
if [ -f "udig.sh" ]
then
   echo "udig.sh has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/udig-conf/udig.sh
fi
# copy it into the udig folder
cp udig.sh /usr/lib/udig

# create link to startup script
ln -s /usr/lib/udig/udig.sh /usr/bin/udig

# Download desktop icon
if [ -f "uDig.desktop" ]
then
   echo "uDig.desktop has already been downloaded."
else
   wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/udig-conf/uDig.desktop
fi
# copy it into the udig folder
cp uDig.desktop $HOME/Desktop


## Sample Data ##

# Download udig's sample data
if [ -f "data-v1_1.zip" ]
then
   echo "data-v1_1.zip has already been downloaded."
else
   wget http://udig.refractions.net/docs/data-v1_1.zip
fi
#unzip the file into /usr/local/share/udig-data
mkdir /usr/local/share/udig-data
unzip data-v1_1.zip -d /usr/local/share/udig-data


## Documentation ##

# Download udig's documentation
if [ -f "udig-1.2-M5.html" ]
then
   echo "udig-1.2-M5.html has already been downloaded."
else
   wget http://udig.refractions.net/files/downloads/branches/udig-1.2-M5.html
fi

if [ -f "uDigWalkthrough1.pdf" ]
then
   echo "uDigWalkthrough1.pdf has already been downloaded."
else
   wget http://udig.refractions.net/docs/uDigWalkthrough1.pdf
fi

if [ -f "uDigWalkthrough2.pdf" ]
then
   echo "uDigWalkthrough2.pdf has already been downloaded."
else
   wget http://udig.refractions.net/docs/uDigWalkthrough2.pdf
fi

#copy into /usr/local/share/udig-docs
mkdir /usr/local/share/udig-docs
cp udig-1.2-M5.html /usr/local/share/udig-docs
cp uDigWalkthrough1.pdf /usr/local/share/udig-docs
cp uDigWalkthrough1.pdf /usr/local/share/udig-docs