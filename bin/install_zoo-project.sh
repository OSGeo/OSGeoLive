#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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
# This script will install ZOO Project

# Running:
# =======
# sudo ./install_zoo-project.sh

# Requires: Apache2, GeoServer (for the demo only)
#
# Uninstall:
# ============
# sudo rm /etc/apache2/conf.d/zoo-project
# sudo rm -rf /var/www/zoo*
# sudo rm -rf /usr/lib/cgi-bin/zoo_loader.cgi
# sudo rm -rf /usr/lib/cgi-bin/proxy.cgi
# sudo rm -rf /usr/lib/cgi-bin/*zcfg
# sudo rm -rf /usr/lib/cgi-bin/ogr_service*
# sudo rm -rf /usr/lib/cgi-bin/main.cfg
# sudo rm -rf /usr/share/applications/zoo-project.desktop
# sudo rm -rf /home/user/Desktop/Servers/zoo-project.desktop

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
ZOO_TMP=/tmp/build_zoo

ZOO_APACHE_CONF="/etc/apache2/conf.d/zoo-project"

mkdir -p "$ZOO_TMP"

# Download ZOO Project LiveDVD tarball.
wget -N --progress=dot:mega "http://zoo-project.org/dl/zoo-livedvd-2011.tar.bz2" \
     -O "$ZOO_TMP/zoo-livedvd.tar.bz2"

# Uncompress ZOO Project LiveDVD tarball.
tar -xjpf "$ZOO_TMP/zoo-livedvd.tar.bz2" -C /

echo -n "Apache configuration update ..."
# Add ZOO Project apache configuration
cat << EOF > "$ZOO_APACHE_CONF"

        <Directory /var/www/zoo/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>

EOF

echo -n "Done\n"

a2enmod rewrite


#Add Launch icon to desktop
if [ ! -e /usr/share/applications/zoo-project.desktop ] ; then
   cat << EOF > /usr/share/applications/zoo-project.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=ZOO Project
Comment=ZOO Project
Categories=Application;Education;Geography;
Exec=firefox http://localhost/zoo-demo/spatialtools.html
Icon=/var/www/zoo-demo/spatialtools_files/zoo-icon.png
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi

cp /usr/share/applications/zoo-project.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/zoo-project.desktop"

rm /etc/ld.so.conf.d/zoo-project.conf
cat > /etc/ld.so.conf.d/zoo-project.conf <<EOF
/usr/lib/jvm/java-6-sun/jre/lib/i386/server
EOF

cd /usr/lib/cgi-bin
ldconfig

# Reload Apache
/etc/init.d/apache2 force-reload
