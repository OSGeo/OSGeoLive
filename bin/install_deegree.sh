#!/bin/bash
#################################################################################
#
# Purpose: Installation of deegree_2.3-with-tomcat_6.0.26-all-in-one into Xubuntu
# Author:  Judit Mays <mays@lat-lon.de>
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
# This script will install deegree-tomcat-all-in-one into Xubuntu
#
# deegree version 2.3 runs with both java-sun-1.5 (preferred) and java-sun-1.6.
# It works best with java-sun-1.5.
#
# It can be installed into servlet containers:
#    Tomcat 5.5.x (but not Tomcat 5.5.26)
#    Tomcat 6.0.x (but not Tomcat 6.0.16)
# The preferred servlet container is Tomcat (version as described above)
#

# Running:
# =======
# sudo ./install_deegree.sh

###########################

TMP="/tmp/build_deegree"
INSTALL_FOLDER="/usr/lib"
DEEGREE_FOLDER="$INSTALL_FOLDER/deegree-2.3_tomcat-6.0.26"
BIN="/usr/bin"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
PASSWORD="user"


### Setup things... ###

## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again."
   exit 1
fi
if [ ! -x "`which java`" ] ; then
   echo "ERROR: java is required, please install a SUN version (preferably java-1.5-sun) and try again."
   exit 1
fi

## create tmp folder
mkdir -p "$TMP"
cd "$TMP"

getWithMd5()
{
    rm -f $1.md5
    wget -nv http://download.deegree.org/LiveDVD/FOSS4G2010/$1.md5

    if (test -f $1) then
        if(md5sum -c $1.md5) then
            echo "$1 has already been downloaded."
            return
        else
            echo "md5 hash is not correct. Downloading $1 again."
            rm -f $1
            wget -c --progress=dot:mega http://download.deegree.org/LiveDVD/FOSS4G2010/$1
        fi
    else
        wget -c --progress=dot:mega http://download.deegree.org/LiveDVD/FOSS4G2010/$1
    fi

    if (md5sum -c $1.md5) then
        echo "md5 hash was ok."
    else
        echo "ERROR [install_deegree.sh]: download of $1 failed."
        exit 1
    fi
}

## TODO: improve. This function does not test on correct md5 sums. 
getFromOsgeo()
{
    echo "FIXME: don't use wget for local files, just copy from local svn checkout."
    rm -f $1
    ## wget -c --progress=dot:mega http://download.deegree.org/LiveDVD/FOSS4G2010/$1
    wget -nv http://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_4/app-conf/deegree/$1
}

### Install Application ###

## get deegree-tomcat-all-in-one
getWithMd5 deegree-2.3_tomcat-6.0.26.tar.gz

## unpack as root, chmod everything to be group/world readable
tar xzf deegree-2.3_tomcat-6.0.26.tar.gz -o -C $INSTALL_FOLDER
chmod -R go+r $INSTALL_FOLDER/apache-tomcat-6.0.26

### Configure Application ###

## Download startup script for deegree
## according to issue 478, the deegree_start.sh script was moved to OSGeo-SVN
#getWithMd5 deegree_start.sh
getFromOsgeo deegree_start.sh
## copy it into the /usr/bin folder
cp deegree_start.sh $BIN

## Download shutdown script for deegree
## according to issue 481, the deegree_stop.sh script was moved to OSGeo-SVN
#getWithMd5 deegree_stop.sh
getFromOsgeo deegree_stop.sh
## copy it into the /usr/bin folder
cp deegree_stop.sh $BIN

## make executable
chmod 755 $BIN/deegree_st*.sh


### install desktop icons ##
if [ ! -e "/usr/share/icons/deegree_desktop_48x48.png" ] ; then
   #wget -nv "http://download.deegree.org/LiveDVD/FOSS4G2010/deegree_desktop_48x48.png"
   echo "FIXME: don't use wget for local files, just copy from local svn checkout."
   wget -nv "http://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_4/app-conf/deegree/deegree_desktop_48x48.png"
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
Comment=deegree v2.3
Categories=Application;Geography;Geoscience;Education;
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
Comment=deegree v2.3
Categories=Application;Geography;Geoscience;Education;
Exec=dash $USER_HOME/launchassist.sh  $BIN/deegree_stop.sh
Icon=/usr/share/icons/deegree_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/deegree-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/deegree-stop.desktop"

