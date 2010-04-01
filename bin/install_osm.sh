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

USER_NAME=user
USER_HOME="/home/$USER_NAME"

TMP_DIR=/tmp/build_osm


apt-get install --assume-yes josm josm-plugins gosmore gpsd merkaartor


#### desktop icons
echo '#!/usr/bin/env xdg-open' > "$USER_HOME"/Desktop/josm.desktop
cat /usr/share/applications/josm.desktop >> "$USER_HOME"/Desktop/josm.desktop
chmod a+x "$USER_HOME"/Desktop/josm.desktop

## need to make one for gosmore
cat << EOF > /usr/share/applications/gosmore.desktop
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Name=Gosmore
Comment=Viewer for OpenStreetMap.com
Exec=/usr/bin/gosmore
Icon=josm-32
StartupNotify=false
Terminal=false
Type=Application
Categories=Education;Science;Geoscience;
EOF

chmod a+x /usr/share/applications/gosmore.desktop
cp /usr/share/applications/gosmore.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/merkaartor.desktop "$USER_HOME/Desktop/"


#### future todo
# install osmrender - it's a renderer from .osm to svg
#   http://wiki.openstreetmap.org/wiki/Osmarender
# two implementations to choose from, one in perl, one in xslt
# download:  http://svn.openstreetmap.org/applications/rendering/osmarender
#  (both implementations and the stylesheets and other stuff is in that svn co)



#### install sample OSM data
mkdir /usr/local/share/osm

# Auckland:
cp ../app-data/osm/Auckland.osm.gz /usr/local/share/osm/



if [ ! -d "$TMP_DIR" ] ; then
   mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


# Barcelona:

### Please update to latest data at the last minute! See data dir on server for details.
wget -c --progress=dot:mega "http://download.osgeo.org/livedvd/data/osm/Barcelona.osm.bz2"
cp Barcelona.osm.bz2 /usr/local/share/osm/


