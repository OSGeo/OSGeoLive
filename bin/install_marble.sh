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

cat << EOF > "/usr/share/applications/marble.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Marble
Comment=Marble
Categories=Application;Education;Geography;
Exec=marble-qt %F
Icon=marble
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF

cp /usr/share/applications/marble.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/marble.desktop"

##-- save 5.5M by removing the unbuilt docbook docs; could change
rm -rf /usr/share/doc/kde/HTML/en/marble


####
./diskspace_probe.sh "`basename $0`" end
