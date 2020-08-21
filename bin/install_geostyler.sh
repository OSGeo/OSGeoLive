#!/bin/sh
#############################################################################
#
# Purpose: This script will install GeoStyler Beginner Workshop
#
#############################################################################
# Copyright (c) 2020 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
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
#############################################################################

# Running:
# =======
# sudo service apache2 start
# Then open a web browser and go to http://localhost/geostyler/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
###

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_geostyler"
NVM_DIR="$USER_HOME/.nvm"


GEOSTYLER_VERSION="4.5.0"
GEOSTYLER_SLD_PARSER_VERSION="2.0.1"
GEOSTYLER_OPENLAYERS_PARSER_VERSION="2.1.0"
NVM_VERSION="0.35.3"
NODE_VERSION="12"
CREATE_REACT_APP_VERSION="3.4.1"
GEOSTYLER_WORKSHOP_COMMIT="240e328d005666978038d8b89b1f3d8613e8d35e"
GEOSTYLER_DIR=/var/www/html/geostyler

#
# Install nvm
#
echo "\nCreating temporary directory $TMP_DIR..."
mkdir -p "$TMP_DIR"
echo "\nCreating directory $GEOSTYLER_DIR..."
mkdir -p "$GEOSTYLER_DIR"


echo "\nDownloading nvm..."
cd "$TMP_DIR"

if [ -f "install_nvm.sh" ]
then
    echo "nvm has already been downloaded."
else
    cat > install_nvm.sh << EOF
#!/bin/bash
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo "\nInstalling nodejs..."
nvm install $NODE_VERSION
echo "\nInstalling geostyler..."
npm i -g geostyler@$GEOSTYLER_VERSION
echo "\nInstalling geostyler-sld-parser..."
npm i -g geostyler-sld-parser@$GEOSTYLER_SLD_PARSER_VERSION
echo "\nInstalling geostyler-openlayers-parser..."
npm i -g geostyler-openlayers-parser@$GEOSTYLER_OPENLAYERS_PARSER_VERSION
echo "\nInstalling create-react-app..."
npm i -g create-react-app@$CREATE_REACT_APP_VERSION
EOF

    chown $USER_NAME:$USER_NAME install_nvm.sh
    chmod +x install_nvm.sh
    cat install_nvm.sh
    su $USER_NAME -c "./install_nvm.sh"
fi

echo "\nDownloading geostyler-workshop"
GS_WORKSHOP_ARCHIVE="$GEOSTYLER_WORKSHOP_COMMIT.zip"
if [ -f "$GS_WORKSHOP_ARCHIVE" ]
then
    echo "\ngeostyler-workshop archive $GS_WORKSHOP_ARCHIVE has already been downloaded. Skipping download."
else
    wget -c --progress=dot:mega \
        "https://github.com/geostyler/geostyler-beginner-workshop/archive/$GEOSTYLER_WORKSHOP_COMMIT.zip"
    echo "\ngeostyler-workshop download complete."
fi


#
# Unzip
#
echo "\nUnzipping archive..."
unzip -qo $GS_WORKSHOP_ARCHIVE
echo "Unzipping done"

#
# Copy to www
#
echo "\nCopying files to $GEOSTYLER_DIR"
cp -r geostyler-beginner-workshop-$GEOSTYLER_WORKSHOP_COMMIT/* $GEOSTYLER_DIR/

#
# Download GeoStyler Logo
#
wget -c --progress=dot:mega \
    "https://raw.githubusercontent.com/geostyler/geostyler/af6153c663bbd9474b152fee632ed292944c2440/public/logo.svg"

#
# Install desktop icon and demo
#

mkdir -p /usr/local/share/icons/ && cp -f "logo.svg" \
       /usr/local/share/icons/geostyler.svg

#
# Launch script and icon for GeoExt
#
echo "\nGenerating launcher..."

if [ ! -e /usr/share/applications/geostyler.desktop ] ; then
   cat << EOF > /usr/share/applications/geostyler.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=GeoStyler
Comment=GeoStyler Workshop
Categories=Application;Internet;
Exec=firefox http://localhost/geostyler/
Icon=geostyler
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/share/applications/geostyler.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/geostyler.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
