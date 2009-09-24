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
# This script will install mapserver

# Running:
# =======
# sudo ./install_mapserver.sh

# Requires: Apache2, PHP5
#
# Uninstall:
# ============
# sudo apt-get remove cgi-mapserver mapserver-bin php5-mapscript python-mapscript
# sudo rm /etc/apache2/conf.d/mapserver
# sudo rm -rf /usr/local/share/mapserver/
# sudo rm -rf /usr/local/www/docs_maps
# sudo rm /usr/lib/cgi-bin/mapserv54

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
DATA_DIR=$USER_HOME/gisvm/trunk/app-data/mapserver
MAPSERVER_DATA=/usr/local/share/mapserver

MS_APACHE_CONF="/etc/apache2/conf.d/mapserver"

# Install MapServer and its php, python bindings.
apt-get install --yes cgi-mapserver mapserver-bin php5-mapscript python-mapscript

# Download MapServer data
[ -d $DATA_DIR ] || mkdir $DATA_DIR
[ -f $DATA_DIR/mapserver-5.4-html-docs.zip ] || wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/mapserver/mapserver-5.4-html-docs.zip" -O $DATA_DIR/mapserver-5.4-html-docs.zip
[ -f $DATA_DIR/mapserver-itasca-ms54.zip ] || wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/mapserver/mapserver-itasca-ms54.zip" -O $DATA_DIR/mapserver-itasca-ms54.zip
[ -f $DATA_DIR/mapserver-gmap-ms54.zip ] || wget -c "https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/mapserver/mapserver-gmap-ms54.zip" -O $DATA_DIR/mapserver-gmap-ms54.zip

# Install docs and demos
if [ ! -d $MAPSERVER_DATA ]; then
    mkdir -p $MAPSERVER_DATA/demos
    echo -n "Extracting MapServer html doc in $MAPSERVER_DATA/....."
    unzip -q $DATA_DIR/mapserver-5.4-html-docs.zip -d $MAPSERVER_DATA/
    echo -n "Done\nExtracting MapServer gmap demo in $MAPSERVER_DATA/demos/..."
    unzip -q $DATA_DIR/mapserver-gmap-ms54.zip -d $MAPSERVER_DATA/demos/ ms4w/apps/gmap/*
    echo -n "Done\nExtracting MapServer itasca demo in $MAPSERVER_DATA/demos/..."
    unzip -q $DATA_DIR/mapserver-itasca-ms54.zip -d $MAPSERVER_DATA/demos/ 
    echo -n "Done\n"
    mv $MAPSERVER_DATA/demos/ms4w/apps/gmap $MAPSERVER_DATA/demos/
    mv $MAPSERVER_DATA/demos/workshop-5.4 $MAPSERVER_DATA/demos/itasca
    mv $MAPSERVER_DATA/mapserver-5.4-docs $MAPSERVER_DATA/doc
    rm -rf $MAPSERVER_DATA/demos/ms4w

    echo -n "Configuring the system...."
    # Itasca Demo hacks
    mkdir -p /usr/local/www/docs_maps/
    ln -s $MAPSERVER_DATA/demos/itasca $MAPSERVER_DATA/demos/workshop-5.4
    ln -s /usr/local/share/mapserver/demos /usr/local/www/docs_maps/mapserver_demos
    ln -s /tmp/ /usr/local/www/docs_maps/tmp
    ln -s /usr/lib/cgi-bin/mapserv /usr/lib/cgi-bin/mapserv54

    # GMap Demo hacks
    # disable javascript by default
    sed -e 's/^.*\$gbIsHtmlMode = 0;  \/\/ Start.*/\$gbIsHtmlMode = 1; \/\/ JavaScript off by default/' $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.phtml > /tmp/gmap75-js-hack.phtml
    mv /tmp/gmap75-js-hack.phtml $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.phtml
    # dbase extension is not needed
    sed -e 's/^.*dl("php_dbase.$dlext");/\/\/dl("php_dbase.$dlext");/' $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.phtml > /tmp/gmap75-dbase-hack.phtml
    mv  /tmp/gmap75-dbase-hack.phtml $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.phtml
    # Modify the IMAGEPATH to point to /tmp
    sed -e 's/^.*IMAGEPATH \"\/ms4w\/tmp\/ms_tmp\/\"/IMAGEPATH \"\/tmp\/\"/' $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.map > /tmp/gmap75-mapfile-hack.phtml
    mv  /tmp/gmap75-mapfile-hack.phtml $MAPSERVER_DATA/demos/gmap/htdocs/gmap75.map
fi

# Add MapServer apache configuration
cat << EOF > $MS_APACHE_CONF
EnableSendfile off
DirectoryIndex index.phtml
Alias /mapserver "/usr/local/share/mapserver"
Alias /ms_tmp "/tmp"
Alias /tmp "/tmp"
Alias /mapserver_demos "/usr/local/share/mapserver/demos"

<Directory "/usr/local/share/mapserver">
   AllowOverride None
   Order allow,deny
   Allow from all
</Directory>

<Directory "/usr/local/share/mapserver/demos">
   AllowOverride None
   Order allow,deny
   Allow from all
</Directory>
EOF

echo -n "Done\n"

#Add Launch icon to desktop
#What Icon should be used
INSTALLED_VERSION=`dpkg -s mapserver | grep '^Version:' | awk '{print $2}' | cut -f1 -d~`
if [ ! -e /usr/share/applications/mapserver.desktop ] ; then
   cat << EOF > /usr/share/applications/mapserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Mapserver
Comment=Mapserver
Categories=Application;Education;Geography;
Exec=firefox /usr/local/share/mapserver/index.html
Icon=
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi
cp /usr/share/applications/mapserver.desktop "$USER_HOME/Desktop/"


# Create the index page
cat <<EOF > $MAPSERVER_DATA/index.html
<html>
<title>MapServer 5.4</title>
<body>
<div id="about">
<h1>About MapServer</h1>
<p>MapServer is an <a href="http://www.opensource.org">Open Source</a> geographic data rendering engine written in C.
Beyond browsing GIS data, MapServer allows you create &#8220;geographic image maps&#8221;,
that is, maps that can direct users to content. For example, the Minnesota DNR
<a href="http://www.dnr.state.mn.us/maps/compass.html">Recreation Compass</a> provides
users with more than 10,000 web pages, reports and maps via a single
application. The same application serves as a &#8220;map engine&#8221; for other portions
of the site, providing spatial context where needed.</p>

<p>MapServer was originally developed by the University of Minnesota (UMN) ForNet
project in cooperation with NASA, and the Minnesota Department of Natural
Resources (MNDNR). Later it was hosted by the TerraSIP project, a NASA
sponsored project between the UMN and a consortium of land management
interests.</p>
<p>MapServer is now a project of <a class="reference external" href="http://www.osgeo.org">OSGeo</a>, and is
maintained by a growing number of developers (nearing 20) from around the
world. It is supported by a diverse group of organizations that fund
enhancements and maintenance, and administered within OSGeo by the MapServer Project Steering Committee made up of developers and other
contributors.</p>
<ul>
<li>Advanced cartographic output<ul>
<li>Scale dependent feature drawing and application execution</li>
<li>Feature labeling including label collision mediation</li>
<li>Fully customizable, template driven output</li>

<li>TrueType fonts</li>
<li>Map element automation (scalebar, reference map, and legend)</li>
<li>Thematic mapping using logical- or regular expression-based classes</li>
</ul>
</li>
<li>Support for popular scripting and development environments<ul>
<li>PHP, Python, Perl, Ruby, Java, and .NET</li>
</ul>
</li>
<li>Cross-platform support<ul>
<li>Linux, Windows, Mac OS X, Solaris, and more</li>

</ul>
</li>
<li>Support of numerous Open Geospatial Consortium  (OGC) standards<ul>
<li>WMS (client/server), non-transactional WFS (client/server), WMC, WCS,
Filter Encoding, SLD, GML, SOS, OM</li>
</ul>
</li>
<li>A multitude of raster and vector data formats<ul>
<li>TIFF/GeoTIFF, EPPL7, and many others via GDAL</li>
<li>ESRI shapfiles, PostGIS, ESRI ArcSDE, Oracle Spatial, MySQL and OGR</li>
</ul>
</li>
<li>Map projection support<ul>
<li>On-the-fly map projection with 1000s of projections through the
Proj.4 library</li>
</ul>
</li>
</ul>
<h1>MapServer Demo</h1>
<ul>
<li><a href="http://localhost/mapserver_demos/itasca/">Itasca</a></li>
<li><a href="http://localhost/mapserver_demos/gmap/htdocs/">GMap</a></li>
</ul>
<h1>MapServer Documentation</h1>
<ul>
<li><a href="/mapserver/doc/">MapServer 5.4.2 Documentation</a></li>
</ul>
</div>
</body>
</html>
EOF

# Reload Apache
/etc/init.d/apache2 force-reload


