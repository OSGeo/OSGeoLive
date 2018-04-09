#!/bin/sh

# Copyright (c) 2009-2018 The Open Source Geospatial Foundation and others.
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

# =============================================================================
# Install script for Geomajas
# =============================================================================

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


TMP="/tmp/build_geomajas"
INSTALL_FOLDER="/usr/lib"  ## hard-wired to repo scripts
BIN=/usr/local/bin
GEOMAJAS_VERSION=2.4.0
GEOMAJAS_HOME="$INSTALL_FOLDER/geomajas-$GEOMAJAS_VERSION-bin"
GEOMAJAS_PORT=3420

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


# =============================================================================
# Pre install checks
# =============================================================================

##### WGET is required to download the Geomajas package:
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

##### Create the TMP directory
mkdir -p "$TMP"
cd "$TMP"


# =============================================================================
# The Geomajas installation process
# =============================================================================

##### Step1: Download Geomajas
echo "Getting Geomajas"
if [ -f "geomajas-$GEOMAJAS_VERSION-bin.zip" ]
then
   echo "geomajas-$GEOMAJAS_VERSION-bin.zip has already been downloaded."
else
   wget -c --progress=dot:mega \
      "http://files.geomajas.org/release/geomajas-$GEOMAJAS_VERSION-bin.zip"
fi


##### Step2: Unzip the package
echo "Unpacking Geomajas in $GEOMAJAS_HOME"
unzip -o -q geomajas-$GEOMAJAS_VERSION-bin.zip -d $INSTALL_FOLDER


##### Step3: Make the scripts executable
chmod 755 "$GEOMAJAS_HOME"
chmod 755 "$GEOMAJAS_HOME/bin"
chmod 755 "$GEOMAJAS_HOME/etc"
chmod 755 "$GEOMAJAS_HOME/lib"

chmod 755 "$GEOMAJAS_HOME/bin/startup.sh"
chmod 755 "$GEOMAJAS_HOME/bin/shutdown.sh"
chmod 755 "$GEOMAJAS_HOME/bin/start_geomajas.sh"
chmod 755 "$GEOMAJAS_HOME/bin/stop_geomajas.sh"


##### Step4: link from bin directory
if [ ! -e "$BIN/geomajas_start.sh" ] ; then
  ln -s $GEOMAJAS_HOME/bin/start_geomajas.sh $BIN/start_geomajas.sh
fi
if [ ! -e "$BIN/geomajas_stop.sh" ] ; then
  ln -s $GEOMAJAS_HOME/bin/stop_geomajas.sh $BIN/stop_geomajas.sh
fi


##### Step5: Make the logs directory writable
chgrp users "$GEOMAJAS_HOME/logs"
chmod g+w "$GEOMAJAS_HOME/logs"
adduser "$USER_NAME" users

#####Make the webapps folder accessible
chmod -R 755 "$GEOMAJAS_HOME/webapps"

# =============================================================================
# Setting up quick-start desktop icons
# =============================================================================

##### Step1: Install desktop icons
echo "Installing Geomajas icons"
if [ ! -e "/usr/share/icons/geomajas_icon_48x48.png" ] ; then
   cp "$GEOMAJAS_HOME/geomajas_icon_48x48.png" /usr/share/icons/
fi


##### Step2: Prepare the start icon
cat << EOF > /usr/share/applications/geomajas-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Geomajas
Comment=Geomajas $GEOMAJAS_VERSION
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/start_geomajas.sh
Icon=/usr/share/icons/geomajas_icon_48x48.png
Terminal=false
EOF

cp -a /usr/share/applications/geomajas-start.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geomajas-start.desktop"


##### Step3: Prepare the stop icon
cat << EOF > /usr/share/applications/geomajas-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Geomajas
Comment=Geomajas $GEOMAJAS_VERSION
Categories=Application;Geography;Geoscience;Education;
Exec=$BIN/stop_geomajas.sh
Icon=/usr/share/icons/geomajas_icon_48x48.png
Terminal=false
EOF

cp -a /usr/share/applications/geomajas-stop.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/geomajas-stop.desktop"


# something possibly screwed up with the ISO permissions:
chgrp tomcat8 /usr/lib/geomajas-$GEOMAJAS_VERSION-bin/bin/*.sh

# share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
ln -s /usr/lib/geomajas-$GEOMAJAS_VERSION-bin/webapps/showcase/WEB-INF/classes/org/geomajas/quickstart/gwt2/shapes \
      /usr/local/share/data/vector/geomajas

# remove local jai libraries to work with ones provided in default-java (fix for #959)
#rm "$GEOMAJAS_HOME"/webapps/showcase/WEB-INF/lib/jai*.jar


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
