#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This program is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
# About:
# =====
# This script will install ushahidi
#
# Requires: Apache2, PHP5 mysql-server
#
# more install instructions can be found here /usr/share/ushahidi/readme.html
#
# Uninstall:
# ============
# sudo rm -rf /var/www/html/ushahidi/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TMP_DIR="/tmp/build_ushahidi"
USHAHIDI_APACHE_CONF="/etc/apache2/conf-available/ushahidi.conf"

mkdir -p "$TMP_DIR"

# Install ushahidi dependencies.
echo "Installing ushahidi"

apt-get --assume-yes install php5 php5-mcrypt php5-curl apache2 \
   php5-gd php5-imap mysql-server libapache2-mod-php5 php5-mysql 

if [ ! -x "`which wget`" ] ; then
    echo "ERROR: wget is required, please install it and try again"
    exit 1
fi

cd "$TMP_DIR"

# The archive changed from .tgz to .zip updating accordingly 
if [ ! -e "ushahidi.zip" ] ; then 
   wget -O ushahidi.zip --progress=dot:mega \
      "https://github.com/ushahidi/Ushahidi_Web/archive/2.7.4.zip"
else
    echo "... Ushahidi already downloaded"
fi

# Uncompress ushahidi
unzip -q "ushahidi.zip"

# Delete the zip file to leave only the extracted folder
rm ushahidi.zip

# Check if '__MACOSX' folder exist. if it does, rm it
if [ -e "__MACOSX" ] ; then
    rm -r __MACOSX
fi

# Now rename the extracted folder to ushahidi
mv * ushahidi

# Now copy the ushahidi folder to a different location
cp -R ushahidi/ /usr/local/share/
ln -s /usr/local/share/ushahidi /var/www/html/ushahidi
chown -R www-data:www-data /usr/local/share/ushahidi

# Check if mysql is running and do appropriate action
if [ `pgrep -cf '/usr/sbin/mysqld'` -eq 0 ] ; then
    echo "Starting mysql.."
    service mysql start
else
    echo "Restarting mysql.."
    service mysql restart
fi

## (Note: on installing mysql-server you should have been prompted to
# Create a new root password. Repeat that here)
MYSQL_ADMIN_NM="root"
MYSQL_ADMIN_PW="user"
echo "
CREATE DATABASE ushahidi;
GRANT ALL PRIVILEGES ON ushahidi.* TO '$USER_NAME'@'localhost' IDENTIFIED BY '$USER_NAME';
" | mysql -u"$MYSQL_ADMIN_NM" -p"$MYSQL_ADMIN_PW"

# Create Ushahidi conf for Apache2
cat << EOF > "$USHAHIDI_APACHE_CONF"
<Directory /var/www/html/ushahidi/>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
 	Order allow,deny
 	allow from all
</Directory>
EOF

# Enable Ushahidi Apache2 conf
a2enconf ushahidi.conf

# Enable Apache2 mod rewrite
a2enmod rewrite

# Enable php5 mcrypt
php5enmod mcrypt

echo "Restarting apache2..."
service apache2 restart


#Add Launch icon to desktop
if [ ! -e /usr/share/applications/ushahidi.desktop ] ; then
   cat << EOF > /usr/share/applications/ushahidi.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Ushahidi
Comment=Ushahidi
Categories=Application;Internet;
Exec=firefox http://localhost/ushahidi
Icon=access
Terminal=false
StartupNotify=false
EOF
fi
cp /usr/share/applications/ushahidi.desktop "$USER_HOME/Desktop/"


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
