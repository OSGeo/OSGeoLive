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
# This script will install GeoServer in xubuntu

# Running:
# =======
# sudo ./install_geoserver.sh

# Requires: Sun Java 6 runtime

TMP="/tmp/gs_downloads"
INSTALL_FOLDER="/usr/lib"
BIN=/usr/bin
GS_VERSION="1.7.6"
GS_HOME="$INSTALL_FOLDER/geoserver-$GS_VERSION"
GS_PORT=8082
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


### Setup things... ###
 
## check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi


### Install proper Sun JDK
echo "Installing Sun JDK 6"
apt-get install --yes sun-java6-jdk

### setup temp ###
mkdir $TMP
cd $TMP

### Download and unpack GeoServer ###

## get GeoServer
echo "Getting GeoServer"
if [ -f "geoserver-$GS_VERSION-bin.zip" ]
then
   echo "geoserver-$GS_VERSION-bin.zip has already been downloaded."
else
   wget "http://sourceforge.net/projects/geoserver/files/GeoServer/$GS_VERSION/geoserver-$GS_VERSION-bin.zip/download"
fi
## unpack it to /usr/lib overwriting eventual existing copy
echo "Unpacking GeoServer in $GS_HOME"
unzip -o -q geoserver-$GS_VERSION-bin.zip -d $INSTALL_FOLDER

### get the RESTConfig extension
echo "Getting GeoServer RESTConfig extension"
if [ -f "geoserver-$GS_VERSION-restconfig-plugin.zip" ]
then
   echo "geoserver-$GS_VERSION-restconfig-plugin.zip has already been downloaded."
else
   wget "http://sourceforge.net/projects/geoserver/files/GeoServer%20Extensions/$GS_VERSION/geoserver-$GS_VERSION-restconfig-plugin.zip/download"
fi
## unpack it
echo "Installing GeoServer RESTConfig extensions"
unzip -o -q geoserver-$GS_VERSION-restconfig-plugin.zip -d $GS_HOME/webapps/geoserver/WEB-INF/lib

### get the styler extension
echo "Getting GeoServer Styler extension"
# yes, it says 1.7.3 because it has not changed since then
if [ -f "styler-1.7.3.zip" ]
then
   echo "styler-1.7.3.zip"
else
   wget "http://downloads.sourceforge.net/geoserver/styler-1.7.3.zip"
fi
## unpack it
echo "Installing GeoServer styler extension"
unzip -o -q styler-1.7.3.zip -d $GS_HOME/data_dir/www


### Configure Application ###

## We need to make sure the scripts use the proper JDK version ##
echo "Configuring GeoServer script for Arramagong"
sed -i "1 i # Force usage of Sun JDK\nexport JAVA_HOME=/usr/lib/jvm/java-6-sun\n# Force proper GeoServer home\nexport GEOSERVER_HOME=$GS_HOME\n" $GS_HOME/bin/startup.sh
sed -i "1 i # Force usage of Sun JDK\nexport JAVA_HOME=/usr/lib/jvm/java-6-sun\n# Force proper GeoServer home\nexport GEOSERVER_HOME=$GS_HOME\n" $GS_HOME/bin/shutdown.sh

## Make Jetty run on a different port
sed -i s/8080/$GS_PORT/g $GS_HOME/etc/jetty.xml

## Make the scripts executable
chmod 755 "$GS_HOME/bin/startup.sh"
chmod 755 "$GS_HOME/bin/shutdown.sh"

## Allow the user to write in the GeoServer data dir
chown -R user:user "$GS_HOME/data_dir"
chown -R user:user "$GS_HOME/logs"

## link from bin directory
if [ ! -e "$BIN/geoserver_start.sh" ] ; then
  ln -s $GS_HOME/bin/startup.sh $BIN/geoserver_start.sh
fi
if [ ! -e "$BIN/geoserver_stop.sh" ] ; then
  ln -s $GS_HOME/bin/shutdown.sh $BIN/geoserver_stop.sh
fi

### install desktop icons ##
echo "Installing GeoServer icons"
if [ ! -e "/usr/share/icons/geoserver_desktop_48x48.png" ] ; then
   wget "http://atlas.openplans.org/~aaime/geoserver_desktop_48x48.png" 
   \mv geoserver_desktop_48x48.png /usr/share/icons/
fi

## start icon
if [ ! -e /usr/share/applications/geoserver-start.desktop ] ; then
   cat << EOF > /usr/share/applications/geoserver-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start GeoServer
Comment=GeoServer 1.7.6
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/geoserver_start.sh
Icon=/usr/share/icons/geoserver_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/geoserver-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geoserver-start.desktop"

## stop icon
if [ ! -e /usr/share/applications/geoserver-stop.desktop ] ; then
   cat << EOF > /usr/share/applications/geoserver-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop GeoServer
Comment=GeoServer 1.7.6
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/geoserver_stop.sh
Icon=/usr/share/icons/geoserver_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/geoserver-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geoserver-stop.desktop"

## admin console icon
if [ ! -e /usr/share/applications/geoserver-admin.desktop ] ; then
   cat << EOF > /usr/share/applications/geoserver-admin.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Admin GeoServer
Comment=GeoServer 1.7.6
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/firefox "http://localhost:$GS_PORT/geoserver/welcome.do"
Icon=/usr/share/icons/geoserver_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/geoserver-admin.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geoserver-admin.desktop"

## styler console icon
if [ ! -e /usr/share/applications/geoserver-styler.desktop ] ; then
   cat << EOF > /usr/share/applications/geoserver-styler.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Style GeoServer
Comment=GeoServer 1.7.6 Styler Extension
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/firefox "http://localhost:$GS_PORT/geoserver/www/styler"
Icon=/usr/share/icons/geoserver_desktop_48x48.png
Terminal=false
EOF
fi

cp -a /usr/share/applications/geoserver-styler.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geoserver-styler.desktop"
