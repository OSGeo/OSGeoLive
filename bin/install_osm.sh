#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
#
# This script is free software; you can redistribute it and/or modify it
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
# This script will install some OpenStreetMap utilities

# Running:
# =======
# sudo ./install_osm.sh

apt-get install --assume-yes josm josm-plugins gosmore gpsd


#### desktop icons
echo '#!/usr/bin/env xdg-open' > /home/user/Desktop/josm.desktop
cat /usr/share/applications/josm.desktop >> /home/user/Desktop/josm.desktop
chmod a+x /home/user/Desktop/josm.desktop

## need to make one for gosmore
# not much point copying this to the desktop until we have a data file builta (see below)
cat << EOF > /usr/share/applications/gosmore.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Name=Gosmore
Comment=Editor for OpenStreetMap.com
Exec=/usr/bin/gosmore
Icon=josm-32
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;
EOF

chmod a+x /usr/share/applications/gosmore.desktop


#### install sample OSM data
#
# - Download OSM planet file from
#  http://www.osmaustralia.org/osmausextract.php
#    or
#  http://downloads.cloudmade.com/oceania/australia
#

# wget -c --progress=dot:mega http:// ... ?
mkdir /usr/local/share/osm
cp ../app-data/osm/Auckland.osm.gz /usr/local/share/osm/


####
# Point gosmore to a sample planet-*.osm data file extract
# ** TODO **
# su - user \   ??
#bzip2 -d planet-...osm.bz2 | gosmore rebuild


