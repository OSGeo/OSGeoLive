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
# This script will install a desktop background image and icon for passwords.

# Running:
# =======
# sudo ./install_desktop.sh
USER_NAME=user
USER_HOME=/home/$USER_NAME

# Default password list on the desktop to be replaced by html help in the future.
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/passwords.txt \
    --output-document=/home/user/Desktop/passwords.txt
chown user:user /home/user/Desktop/passwords.txt

# Setup the desktop background
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/desktop-conf/arramagong-desktop.png \
    --output-document=/usr/share/xfce4/backdrops/arramagong-desktop.png

#Has to been run as the regular user
sudo -u $USER_NAME xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path \
    -s /usr/share/xfce4/backdrops/arramagong-desktop.png

#Add the launchhelp script which allows other apps to provide sudo launching with the password already embedded
#Geonetwork and deegree needs this right now
cp ${USER_HOME}/gisvm/trunk/bin/launchassist.sh ${USER_HOME}/.
chmod 755 ${USER_HOME}/launchassist.sh