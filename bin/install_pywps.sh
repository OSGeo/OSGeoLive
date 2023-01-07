#!/bin/sh
#############################################################################
#
# Purpose: This script will pywps
#
#############################################################################
# Copyright (c) 2016-2023 The Open Source Geospatial Foundation.
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

# This script will install pywps as follows
# - python-pywps debian package
# - /etc/pywps (configuration, WSGI wrapper, processes)
# - /etc/apache2/sites-available/pywps.conf
# - /usr/share/applications/pywps.desktop
#
# Requires: Apache2, Python, python-pywps
#
# Uninstall:
# ============
# sudo apt-get remove python libapache2-mod-wsgi python-pywps
#
# sudo a2disconf pywps
# sudo a2dismod wsgi
# sudo apache2ctl restart
# sudo rm -fr /usr/local/share/pywps
# sudo rm -f /etc/apache2/conf-available/pywps.conf
# sudo rm -f /usr/share/applications/pywps.desktop
# sudo rm -f /home/$USER_NAME/Desktop/pywps.desktop


./diskspace_probe.sh "`basename $0`" begin
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo 'Installing PyWPS ...'

apt-get install --yes pywps

PYWPS_URL=http://localhost/pywps/wps.py
PYWPS_DESKTOP=/usr/share/applications/pywps.desktop

echo 'Downloading logo'

wget -c --progress=dot:mega \
   -O /usr/local/share/icons/pywps.png \
   "http://pywps.org/images/pywps.png"

echo 'creating desktop launcher'

cat << EOF > "$PYWPS_DESKTOP"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=PyWPS
Comment=PyWPS
Categories=Application;Education;Geography;WPS
Exec=firefox $PYWPS_URL?service=WPS&version=1.0.0&request=GetCapabilities
Icon=/usr/local/share/icons/pywps.png
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF

cp "$PYWPS_DESKTOP" "$USER_HOME/Desktop"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/pywps.desktop"

echo 'enabling Apache wsgi module'
a2enmod wsgi
echo 'enabling Apache configuration'
a2enconf pywps-wsgi

####
./diskspace_probe.sh "`basename $0`" end
