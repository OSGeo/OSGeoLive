#!/bin/bash
#################################################################################
#
# Purpose: Installation of deegree-webservices-3.2-pre3-with-apache-tomcat_6.0.35-all-in-one into Xubuntu
# Author:  Judit Mays <mays@lat-lon.de>, Johannes Kuepper <kuepper@lat-lon.de>
# Credits: Stefan Hansen <shansen@lisasoft.com>
#          H.Bowman <hamish_b  yahoo com>
# Date:    $Date$
# Revision:$Revision$
#
#################################################################################
# Copyright (c) 2009 lat/lon GmbH
# Copyright (c) 2009 Uni Bonn
#
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
#################################################################################

# About:
# =====
# This script will install deegree-webservices-tomcat-all-in-one into Xubuntu
#
# deegree webservices version 3.2-pre3 runs with java-sun-1.6 on Apache Tomcat 6.0.35
#

# Running:
# =======
# sudo ./install_deegree.sh

###########################

TMP="/tmp/build_deegree"
INSTALL_FOLDER="/usr/lib"
DEEGREE_FOLDER="$INSTALL_FOLDER/deegree-webservices-3.2-pre3_apache-tomcat-6.0.35"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
PASSWORD="user"
BUILD_DIR=`pwd`
TOMCAT_PORT=8033


### Setup things... ###

## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again."
   exit 1
fi
if [ ! -x "`which java`" ] ; then
   echo "ERROR: java is required, please install java-1.6-sun and try again."
   exit 1
fi

## create tmp folder
mkdir -p "$TMP"
cd "$TMP"

getWithMd5()
{
    rm -f $1.md5
    wget -nv http://download.deegree.org/LiveDVD/FOSS4G2012/$1.md5

    if (test -f $1) then
        if(md5sum -c $1.md5) then
            echo "$1 has already been downloaded."
            return
        else
            echo "md5 hash is not correct. Downloading $1 again."
            rm -f $1
            wget -c --progress=dot:mega http://download.deegree.org/LiveDVD/FOSS4G2012/$1
        fi
    else
        wget -c --progress=dot:mega http://download.deegree.org/LiveDVD/FOSS4G2012/$1
    fi

    if (md5sum -c $1.md5) then
        echo "md5 hash was ok."
    else
        echo "ERROR [install_deegree.sh]: download of $1 failed."
        exit 1
    fi
}

### Install Application ###

## get deegree-tomcat-all-in-one
getWithMd5 deegree-webservices-3.2-pre3_apache-tomcat-6.0.35.tar.gz

## unpack as root, chmod everything to be group/world readable
tar xzf deegree-webservices-3.2-pre3_apache-tomcat-6.0.35.tar.gz -o -C $INSTALL_FOLDER
chmod -R go+r $DEEGREE_FOLDER/*

### Configure Application ###

## Download startup script for deegree
getWithMd5 deegree_start.sh
## copy it into the /usr/bin folder
cp deegree_start.sh $BIN

## Download shutdown script for deegree
getWithMd5 deegree_stop.sh
## copy it into the /usr/bin folder
cp deegree_stop.sh $BIN

## make start and stop script executable
chmod 755 $BIN/deegree_st*.sh


### install desktop icons ##
if [ ! -e "/usr/share/icons/deegree_desktop_48x48.png" ] ; then
   wget -nv "http://download.deegree.org/LiveDVD/FOSS4G2012/deegree_desktop_48x48.png"
   mv deegree_desktop_48x48.png /usr/share/icons/
fi

if(test ! -d $USER_HOME/Desktop) then
    mkdir $USER_HOME/Desktop
fi

## start icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-start.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start deegree
Comment=deegree webservices 3.2-pre3
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/launchassist.sh $BIN/deegree_start.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-start.desktop"

## stop icon
##Relies on launchassist in home dir
if [ ! -e /usr/share/applications/deegree-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/deegree-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop deegree
Comment=deegree webservices 3.2-pre3
Categories=Application;Geoscience;OGC Web Services;SDI;Geography;Education;
Exec=dash $USER_HOME/launchassist.sh  $BIN/deegree_stop.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-stop.desktop"


# something screwed up with the ISO permissions:
chgrp tomcat6 /usr/lib/deegree-webservices-3.2-pre3_apache-tomcat-6.0.35/bin/*.sh


## last minute hack to work around conflict with system's tomcat
##    (both want to use port 8080; deegree loses)
cp -f "$BUILD_DIR"/../app-conf/deegree/deegree_st*.sh "$BIN"/

# forcibly change to another port
cd "$DEEGREE_FOLDER"
sed -i -e "s/8080/$TOMCAT_PORT/" \
       -e 's/8005/8006/' \
       -e 's/8443/8444/' \
   conf/server.xml


cd webapps/deegree-webservices/
FILES_TO_EDIT="
console/wms/js/sextante.js
console/wps/openlayers-demo/proxy.jsp
console/wps/openlayers-demo/sextante.js
resources/deegree-workspaces/deegree-workspace-csw/services/main.xml
"

sed -i -e "s/localhost:8080/localhost:$TOMCAT_PORT/g" \
       -e "s/127.0.0.1:8080/127.0.0.1:$TOMCAT_PORT/g" \
   $FILES_TO_EDIT


