#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install pywps
#
# Requires: Apache2, Python, lxml
#
# Uninstall:
# ============
# sudo apt-get remove cgi-mapserver mapserver-bin python python-lxml
# sudo rm /etc/pywps/pywps.cfg
# sudo rm /usr/local/bin/wps.py
# sudo rm /usr/lib/cgi-bin/pywps
# sudo rm -rf /usr/local/lib/python2.7/dist-packages/pywps-3.2.2_master-py2.7.egg
# sudo rm -rf /usr/local/share/pywps

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

PYWPS_VERSION=3.2.2
PYWPS_OUTPUTS="/var/www/wps/wpsoutputs"
PYWPS_WORKING_DIR="/usr/local/share/pywps"
PYWPS_PROCESSES="$PYWPS_WORKING_DIR/processes"
PYWPS_CFG="$PYWPS_WORKING_DIR/pywps.cfg"
PYWPS_DOCS="$PYWPS_WORKING_DIR/docs"
ICON_NAME="pywps.png"

TMP_DIR="/tmp/build_pywps"
mkdir "$TMP_DIR"
cd "$TMP_DIR"

# desktop icon
wget "http://pywps.wald.intevation.org/_static/pywps.png"
cp "$ICON_NAME" /usr/local/share/icons/


# Install PyWPS and its php, python bindings.
apt-get install --yes python python-lxml wget

# create working directory
mkdir -p "$PYWPS_WORKING_DIR"
mkdir -p "$PYWPS_OUTPUTS"
mkdir -p "$PYWPS_PROCESSES"
chmod 777 "$PYWPS_OUTPUTS"

# Download PyWPS
wget -c "https://github.com/geopython/PyWPS/aaggrchive/pywps-3.2.2.tar.gz"
tar xzf pywps-3.2.2.tar.gz
cd PyWPS-pywps-3.2.2

# install
python setup.py install

# create configuration file
cat << EOF > "$PYWPS_CFG"
echo "[wps]
encoding=utf-8
title=PyWPS OSGeo-Live server
version=1.0.0
abstract=PyWPS distribution for OSGeo-Live project
fees=None
constraints=none
serveraddress=http://localhost/cgi-bin/pywps
keywords=PyWPS,OSGeo
lang=eng

[provider]
providerName=OSGeo
individualName=Jachym
positionName=Code writer
role=PyWPS Contant persion
deliveryPoint=Here
city=There
postalCode=000 00
country=Internet
electronicMailAddress=pywps-dev@lists.osgeo.org
providerSite=http://pywps.wald.intevation.org
phoneVoice=False
phoneFacsimile=False
administrativeArea=False

[server]
maxoperations=50
maxinputparamlength=1024
maxfilesize=3mb
tempPath=/var/www/pywps
output>Url=http://localhost/wps/
outputPath=$PYWPS_OUTPUTS
debug=true
EOF

# copy processes to target dir
cp tests/processes/* "$PYWPS_PROCESSES"

# Create wrapper script
cat << EOF > "/usr/lib/cgi-bin/pywps"
#!/bin/sh
PYWPS_CFG=${PYWPS_CFG}
PYWPS_PROCESSES=${PYWPS_PROCESSES}
/usr/local/bin/wps.py
EOF

chmod 755 "/usr/lib/cgi-bin/pywps"



# Install docs and demos
cd doc
make html
mkdir -p "$PYWPS_DOCS"
cp -r build/html/* "$PYWPS_DOCS"

cat << EOF > "/usr/share/applications/pywps.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=PyWPS
Comment=PyWPS
Categories=Application;Education;Geography;WPS
Exec=firefox http://localhost/cgi-bin/pywps?service=wps&request=getcapabilities
Icon=/usr/local/share/icons/$ICON_NAME
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF


cp /usr/share/applications/pywps.desktop "$USER_HOME/Desktop/Web Services"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/Web Services/pywps.desktop"


# clean installation
cd
rm -rf "$TMP_DIR"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end