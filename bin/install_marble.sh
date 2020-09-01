#!/bin/sh
#############################################################################
#
# Purpose: This script will install marble
#
#############################################################################
# Copyright (c) 2009-2020 The Open Source Geospatial Foundation and others.
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
#############################################################################

# Running:
# =======
# sudo ./marble_install.sh

./diskspace_probe.sh "`basename $0`" begin
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


apt-get install --yes marble-qt marble-data marble-plugins

# install icon
mkdir -p /usr/local/share/icons/
cp -f "$USER_HOME/gisvm/app-conf/marble/marble_logo.png" \
       /usr/local/share/icons/

# create .desktop file
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/marble.desktop ] ; then
   cat << EOF > /usr/local/share/applications/marble.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Marble
Comment=Marble-Qt
Categories=Education;Science;Geoscience;
Exec=marble-qt
Icon=/usr/local/share/icons/marble_logo.png
Terminal=false
EOF
fi

cp -v /usr/local/share/applications/marble.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/marble.desktop"

##-- save 5.5M by removing the unbuilt docbook docs; could change
rm -rf /usr/share/doc/kde/HTML/en/marble


####
./diskspace_probe.sh "`basename $0`" end
