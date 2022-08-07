#!/bin/sh
#############################################################################
#
# Purpose: Install OSGeoLive packages that are only available in Virtual
#     Machine version
# Author:  Angelos Tzotsos <tzotsos@gmail.com>
#
#############################################################################
# Copyright (c) 2010-2022 Open Source Geospatial Foundation (OSGeo) and others.
#
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

if [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: sudo install_vm_only.sh [ARCH(i386 or amd64)]"
    exit 1
fi

if [ "$#" -eq 1 ]; then
    ARCH="amd64"
else
    if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
        echo "Did not specify build architecture, try using i386 or amd64 as an argument"
        echo "Usage: sudo install_vm_only.sh [ARCH(i386 or amd64)]"
        exit 1
    fi
    ARCH="$1"
fi

echo
echo "==============================================================="
echo "Build parameters"
echo "==============================================================="

echo "ARCH: $ARCH"

DIR="/usr/local/share/gisvm/bin"
# GIT_DIR="/usr/local/share/gisvm"
# BUILD_HOME="/home/user"
# VERSION=`cat "$DIR"/../VERSION.txt`

USER_NAME="user"
export USER_NAME
USER_HOME="/home/$USER_NAME"

# We want the git repo available in VM version for development
# cp "$DIR"/bootstrap.sh /home/user/bootstrap.sh
# rm -rf /usr/local/share/gisvm
# cd /home/user
# chmod a+x bootstrap.sh
# ./bootstrap.sh

apt-get -q update
apt-mark unhold linux-image-generic
apt-get --yes upgrade

# Install linux headers
apt-get install --yes build-essential linux-headers-generic

# Adding VBox guest additions
apt-get install --yes virtualbox-guest-x11

# Adding development packages that were removed from iso to save disk space
apt-get --yes install build-essential git gnupg devscripts debhelper \
  gcc-11 g++-11 gfortran-11 pbuilder pristine-tar git-buildpackage devscripts \
  grass-dev libgdal-dev libproj-dev libgeos-dev python3-dev python3-pip \
  cmake libotb-dev npm nodejs python3-dask python3-sklearn python3-cfgrib

# Adding Python2
apt-get install --yes python-all-dev

# Adding back LibreOffice and other packages that were removed from iso to save disk space
apt-get --yes install libreoffice libreoffice-common libreoffice-core 2048-qt noblenote trojita \
  transmission-common k3b vlc libllvm14 fonts-dejavu fonts-dejavu-extra xfonts-scalable \
  xfonts-100dpi xfonts-75dpi xfonts-jmk fonts-lyx unifont fonts-noto-core fonts-noto \
  fonts-noto-cjk fonts-noto-mono

# Remove patches needed for the live session only
rm "$USER_HOME"/.config/autostart/apache-fixer.desktop
rm "$USER_HOME"/.config/autostart/desktop-truster.desktop

# Install R Studio
cd ~
apt-get --yes install libclang-dev
wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2022.07.0-548-amd64.deb
dpkg -i rstudio-server-2022.07.0-548-amd64.deb
rm rstudio-server-2022.07.0-548-amd64.deb
systemctl disable rstudio-server
# TODO: Install Atom or VS Code

# Install docker engine
apt-get --yes install docker.io docker-compose
usermod -aG docker user
# TODO: Install extra documentation

cd "$DIR"

# ./base_language.sh
./install_gmt.sh
./install_gvsig.sh "$ARCH"
./install_udig.sh "$ARCH"
./install_52nSOS.sh
# ./install_actinia.sh
./install_ncWMS.sh
./install_rasdaman.sh
./install_re3gistry.sh
./install_etf.sh
./install_pgadmin.sh
# ./install_icons_and_menus.sh

# Cleanup
rm -rf /tmp/build_*

echo
echo "==============================================================="
echo "Finished building Virtual Machine"
echo "==============================================================="
