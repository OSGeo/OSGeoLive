#!/bin/bash
#
# Copyright (c) 2009-2010 The Open Source Geospatial Foundation.
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
# This script will install geomoose

# Running:
# =======
# sudo ./install_geomoose.sh

apt-get --assume-yes install php5-sqlite

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_DIR="/home/$USER_NAME"

mkdir -p /tmp/build-geomoose

cd /tmp/build-geomoose

# Download and extract GeoMOOSE 2.4
wget -c --progress=dot:mega \
   "http://www.geomoose.org/downloads/geomoose-2.4.tar.gz"
wget -c -nv \
   "http://www.geomoose.org/downloads/geomoose-2.4-mapserver-6.patch"
wget -c -nv \
   "http://www.geomoose.org/downloads/geomoose-2.4-mapbook.xml.in.patch"

tar -xzf geomoose-2.4.tar.gz

rm -rf /usr/local/geomoose

mkdir -p /usr/local/geomoose

cd /usr/local/geomoose

mv /tmp/build-geomoose/geomoose*/* .

# Setup htdocs directory to be available to apache
ln -s /usr/local/geomoose/htdocs /var/www/geomoose

# Patch GeoMOOSE State Demo layer to work with MapServer 6.x
# Patches are submitted upstream and will likely be included
# (or their equivlent) in GeoMOOSE 2.6.
patch -p1 < /tmp/build-geomoose/geomoose-2.4-mapserver-6.patch
patch -p1 < /tmp/build-geomoose/geomoose-2.4-mapbook.xml.in.patch

# Configure GeoMOOSE 2.4 (Builds configuration files from templates)
./configure --with-url-path=/geomoose --with-temp-directory=/tmp/ \
   --with-mapfile-root=/usr/local/geomoose/maps/

## Install icon
base64 -d > /usr/share/icons/geomoose.png <<'EOF'
iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAAAXNSR0IArs4c6QAAAmRQTFRFXy4A
US0EViwAWC0AVC8HWi8CVTAIXi4DYC4AWzAAVjEJYS8AXDEAXDEEYjAAWDMEXTIAXjIAQjcjYzEA
XjIGWTQFXzMAZDIBYDQAWzUHWjUNZTMCYTUBZjQAXTYIZjQDZzUAaDUAXTcQaTYAXzgKajcAYToM
bDgASj4qWzsXYDoTYjsNYTsTXDwYTEAsYjwUZDwPXz0UYzwVXj0abzsAdToAYz0bcDwAdjsAZT4X
cT0AT0MvNkhSTkQ0UEQveD0APklKUUYxej8BZEMfUUc3e0ACZkQaUkc4a0MbU0g5ZkUhTko5SUpI
VEk6T0s6VUo7UU07akgkV0w8bEomWU4+bUsnVFFFcE4vT1dTWldKW1hLXFtTX11QTWNnYWFZYmFa
Z2RXYGllaWhgYWplX2tsamlhY2xnY29wZHBxb25mcG9nYXN+b3FuaHR1anZ2XnmCa3d3bHh4b3hz
YXyFcnt2eHp3cn5+Z4KLZIOSdYGBdomVbYybgYiQh4mGc46YgIyNcpGgiJGMgpWhhpWbfJurdZ23
g56of5+ufaG2gaGwfqK3j5+ljaCrf6O4kKCmg6e8mamvha7Ihq/Jh7DLirLNkrHBmbDBi7POkbXK
jrbRj7fSkLjTorbCjbvbkrvWjrzciL/ej73enrrRicDfkL7fisHgkr/glr/ajMPioL/PlMHimcLd
nsLXm8PenMTfocXbnsbiosbco8fdpMjepcnfpsrgp8zhqM3isMzkqs7ktc3fr8/frNDmts7gt8/h
uNDir9PputHjvdHdu9LkvtLetdXlvNPlv9PfwdXiu9fivNjjvdnxDgmrswAAAAF0Uk5TAEDm2GYA
AAIUSURBVEjHY2AYBaNgFIyCwQa4GElQrAvEYsLEq+cXBxLSyixAa1DEyydNmegf1puN6hIgllDn
ZVBSVg9nYJB3Q5Kq62ravGVbjnXnRGQNwlIMDHxWHgxmyurGDKHKrAwMvBAJIU/HkEV7tu/oi9+8
dn4xREyUgSFYmQ+kQY3BSFndmUFTnQnIkwTJRfh6uzQfSO0+eGzvti3rFkM08GkxsCkLgDRYMhhK
W7EyMJtKMwRKi3kB5dI8vX2tS0Iya08c37dt2/JZIPU6ypIMKlbiDMbKVgbAULJXllN3shIRszBV
lhZuj/IGAt+ExpOnTu3bvXnDzCpubml1J/FQZVcrNTF7dSOgdgkJCTExMRApyM47P9Lb29PT/wRQ
/alD+zZv6ZjIKyYhJiwuLszHJywuLIYR0svSPR1rSuecOnXyxKmD+7Zs6QrCHzMZyxYXaqzct/cQ
0IIje3dt3pbsn4xXQ8qyZZvXl5WePnb04L69e7dt3twSkEtAw+J1mzcXZUXFJE3Yu33zlo2TCgik
lgXLlm3ZvH2qt6+nbWXPmi3Lly0moGHesmVrt2zZ5O8LDFy9aWuXLZ5FQEP+ssXL1m7est3T09O6
fsOyZUtjCaXgScuAYN3mIPe4GSuAmqcTTvPzlwHVzXfJA1HL5vsQkUuA3lg2O3oBUPmyWcTlq4ZV
y+a2Llu8eFkF0VnRobytv9pmqJRKABe7tCLpv/eEAAAAAElFTkSuQmCC
EOF

## Install menu and desktop shortcuts
cat << EOF > /usr/share/applications/GeoMOOSE.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
Name=GeoMOOSE
Comment=View GeoMOOSE sample application in browser
Categories=Application;Geography;Geoscience;Education;
Exec=sensible-browser http://localhost/geomoose/geomoose.html
Icon=/usr/share/icons/geomoose.png
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/GeoMOOSE.desktop $USER_DIR/Desktop/
chown $USER_NAME:$USER_NAME $USER_DIR/Desktop/GeoMOOSE.desktop

# share data with the rest of the disc
mkdir -p /usr/local/share/data/vector
ln -s /usr/local/geomoose/maps/demo \
      /usr/local/share/data/vector/geomoose

