#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
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

# About:
# =====
# This script will install gvSIG 1.9rc1 (BN1242) using
# a deb package. It will also download the gvSIG manual

# Running:
# =======
# Go to Applications -> Accesories -> gvSIG or
# just double-click on Desktop gvSIG Icon file

# install dependencies
apt-get install libstdc++5 libgdal1-1.5.0 sun-java5-jre

# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

# create tmp folders
TMP=/tmp/gvsig_downloads

if [ ! -d $TMP ] ; then
   mkdir cd $TMP
fi

cd $TMP

# get deb package
GVSIG_PACKAGE="gvsig_1.9.0RC1_i386.deb"
GVSIG_PATH="http://gvsig-desktop.forge.osor.eu/downloads/people/iver"

if [ -f $GVSIG_PACKAGE ]
then
   echo "$GVSIG_PACKAGE has already been downloaded."
else
   wget -c $GVSIG_PATH/$GVSIG_PACKAGE
fi

# install the deb package
dpkg -i $GVSIG_PACKAGE

# place a gvSIG icon on desktop
cp /usr/share/applications/gvsig.desktop /home/user/Desktop


# download documentation
GVSIG_DOCS=/usr/local/share/gvsig
GVSIG_MAN=gvSIG-1_1-man-v1-en.pdf

if [ ! -d $GVSIG_DOCS ] ; then
   mkdir cd $GVSIG_DOCS
fi

if [ -f "$GVSIG_MAN" ]
then
   echo "$GVSIG_MAN has already been downloaded."
else
   wget ftp://downloads.gvsig.org/gva/descargas/manuales/$GVSIG_MAN
fi

cp $GVSIG_MAN $GVSIG_DOCS

echo "Done!"

