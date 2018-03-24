#!/bin/sh
# Copyright (c) 2012-2018 Open Source Geospatial Foundation (OSGeo) and others.
#
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
# This script installs EOxServer.

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
    USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# Set EOxServer version to install
EOXSVER="0.4.0"

DATA_DIR="/usr/local/share/eoxserver"
DOC_DIR="$DATA_DIR/doc"
APACHE_CONF_FILE="eoxserver.conf"
APACHE_CONF_DIR="/etc/apache2/conf-available/"
APACHE_CONF=$APACHE_CONF_DIR$APACHE_CONF_FILE
TMP_DIR="/tmp/build_eoxserver"
POSTGRES_USER="$USER_NAME"


## check required tools are installed
if [ ! -x "`which wget`" ] ; then
    apt-get --assume-yes install wget
fi


#Install packages
apt-get -q update
apt-get --assume-yes install python-gdal libxml2 python-lxml python-psycopg2 \
    python-libxml2 cgi-mapserver python-mapscript libapache2-mod-wsgi python-eoxserver 

if [ $? -ne 0 ] ; then
    echo 'ERROR: Package install failed! Aborting.'
    exit 1
fi


if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"

# Create database for demonstration instance
sudo -u $POSTGRES_USER createdb eoxserver_demo
sudo -u $POSTGRES_USER psql eoxserver_demo -c 'create extension postgis;'


# Create demonstration instance
[ -d "$DATA_DIR" ] || mkdir -p "$DATA_DIR"

cd "$DATA_DIR"
chmod -R g+w "$DATA_DIR"
chgrp -R users "$DATA_DIR"
adduser user users

if [ ! -d eoxserver_demonstration ] ; then
    echo "Creating EOxServer demonstration instance"
    eoxserver-admin.py create_instance eoxserver_demonstration

    cd eoxserver_demonstration

    # Configure database
    sed -e "s/'ENGINE': .*/'ENGINE': 'django.contrib.gis.db.backends.postgis',/" \
        -i eoxserver_demonstration/settings.py
    sed -e "s/'NAME': .*/'NAME': 'eoxserver_demo',/" \
        -i eoxserver_demonstration/settings.py
    sed -e "s/'USER': .*/'USER': '$POSTGRES_USER',/" \
        -i eoxserver_demonstration/settings.py
    sed -e "s/'PASSWORD': .*/'PASSWORD': '$POSTGRES_USER',/" \
        -i eoxserver_demonstration/settings.py
    sed -e "/#'TEST_NAME': .*/d" \
        -i eoxserver_demonstration/settings.py
    sed -e "s/'HOST': .*/'HOST': 'localhost',/" \
        -i eoxserver_demonstration/settings.py
    sed -e "/'PORT': .*/d" \
        -i eoxserver_demonstration/settings.py

    sed -e 's/DEBUG = True/DEBUG = False/' -i eoxserver_demonstration/settings.py

    # Further configuration
    echo "ALLOWED_HOSTS = ['*']" >> eoxserver_demonstration/settings.py

    # Initialize database
    python manage.py syncdb --noinput

    # Download and register demonstration data
    wget -c --progress=dot:mega \
       "https://github.com/EOxServer/eoxserver/archive/release-$EOXSVER.tar.gz"

    echo "Extracting demonstration data in `pwd`."
    tar -xzf release-$EOXSVER.tar.gz
    chown -R root.root eoxserver-release-*

    mkdir -p eoxserver_demonstration/data/fixtures/
    mv eoxserver-release-$EOXSVER/autotest/autotest/data/fixtures/auth_data.json \
        eoxserver-release-$EOXSVER/autotest/autotest/data/fixtures/range_types.json \
        eoxserver_demonstration/data/fixtures/

    mkdir -p eoxserver_demonstration/data/meris/
    mv eoxserver-release-$EOXSVER/autotest/autotest/data/meris/README \
        eoxserver_demonstration/data/meris/
    mv eoxserver-release-$EOXSVER/autotest/autotest/data/meris/mosaic_MER_FRS_1P_reduced_RGB/ \
        eoxserver_demonstration/data/meris/

    rm release-$EOXSVER.tar.gz
    rm -r eoxserver-release-$EOXSVER/

    python manage.py loaddata eoxserver_demonstration/data/fixtures/auth_data.json eoxserver_demonstration/data/fixtures/range_types.json
    python manage.py eoxs_collection_create -i MER_FRS_1P_RGB_reduced

    python manage.py eoxs_dataset_register --collection MER_FRS_1P_RGB_reduced -d "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_RGB_reduced.tif -m "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060816_090929_000001972050_00222_23322_0058_RGB_reduced.xml -r RGB
    python manage.py eoxs_dataset_register --collection MER_FRS_1P_RGB_reduced -d "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced.tif -m "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060822_092058_000001972050_00308_23408_0077_RGB_reduced.xml -r RGB
    python manage.py eoxs_dataset_register --collection MER_FRS_1P_RGB_reduced -d "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060830_100949_000001972050_00423_23523_0079_RGB_reduced.tif -m "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_reduced_RGB/mosaic_ENVISAT-MER_FRS_1PNPDE20060830_100949_000001972050_00423_23523_0079_RGB_reduced.xml -r RGB

    touch eoxserver_demonstration/logs/eoxserver.log
    chown www-data eoxserver_demonstration/logs/eoxserver.log

    # Collect static files
    python manage.py collectstatic --noinput

    # Configure WSGI
    sed -e "s,^import os$,import os\nimport sys\n\npath = \"$DATA_DIR/eoxserver_demonstration/\"\nif path not in sys.path:\n    sys.path.insert(0, path)\n," \
        -i eoxserver_demonstration/wsgi.py

    chmod g+w -R .
    chgrp users -R .
fi


# Django 1.6 results in a bug, thus install 1.5 locally for the moment
# sudo pip install django==1.5.12 -t "$DATA_DIR/eoxserver_demonstration"

#### final tidy up
sudo -u "$POSTGRES_USER" psql eoxserver_demo -c 'VACUUM ANALYZE;'

# Deploy demonstration instance in Apache
echo "Deploying EOxServer demonstration instance"
cat << EOF > "$APACHE_CONF"
Alias /eoxserver_demonstration_static "$DATA_DIR/eoxserver_demonstration/eoxserver_demonstration/static"
Alias /eoxserver "$DATA_DIR/eoxserver_demonstration/eoxserver_demonstration/wsgi.py"

WSGIDaemonProcess eoxserver processes=5 threads=1
<Directory "$DATA_DIR/eoxserver_demonstration/eoxserver_demonstration">
    AllowOverride None
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    AddHandler wsgi-script .py
    WSGIProcessGroup eoxserver
    Require all granted
</Directory>
EOF
a2enconf $APACHE_CONF_FILE
echo "Done"


# Install desktop icon
echo "Installing EOxServer icon"
if [ ! -e "/usr/share/icons/eoxserver_60x60.logo.png" ] ; then
    wget -c --progress=dot:mega \
        "https://raw.github.com/EOxServer/osgeo-live/master/logo-eoxserver-3.png" \
        -O /usr/share/icons/eoxserver_60x60.logo.png
fi


# Add Launch icon to desktop
if [ ! -e /usr/local/share/applications/eoxserver.desktop ] ; then
    cat << EOF > /usr/local/share/applications/eoxserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=EOxServer
Comment=EOxServer
Categories=Application;Geography;Geoscience;Education;
Exec=firefox http://localhost/eoxserver/
Icon=/usr/share/icons/eoxserver_60x60.logo.png
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/local/share/applications/eoxserver.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/eoxserver.desktop"


# EOxServer Documentation
echo "Getting EOxServer documentation"
[ -d "$DOC_DIR" ] || mkdir -p "$DOC_DIR"

cd "$DOC_DIR"
chmod g+w .
chgrp users .

wget -c --progress=dot:mega \
    "https://media.readthedocs.org/pdf/eoxserver/0.4/eoxserver.pdf" \
    -O EOxServer_documentation-$EOXSVER.pdf

ln -sf EOxServer_documentation-$EOXSVER.pdf EOxServer_documentation.pdf
chmod g+w -R EOxServer_documentation*
chgrp users -R EOxServer_documentation*
ln -sTf "$DOC_DIR" /var/www/html/eoxserver-docs

# # Add Documentation Launch icon to desktop
# if [ ! -e /usr/local/share/applications/eoxserver-docs.desktop ] ; then
#     cat << EOF > /usr/local/share/applications/eoxserver-docs.desktop
# [Desktop Entry]
# Type=Application
# Encoding=UTF-8
# Name=EOxServer Documentation
# Comment=EOxServer Documentation
# Categories=Application;Geography;Geoscience;Education;
# Exec=evince "$DOC_DIR/EOxServer_documentation.pdf"
# Icon=/usr/share/icons/eoxserver_60x60.logo.png
# Terminal=false
# StartupNotify=false
# EOF
# fi
# cp -a /usr/local/share/applications/eoxserver-docs.desktop "$USER_HOME/Desktop/"
# chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/eoxserver-docs.desktop"


# Reload Apache
service apache2 --full-restart


# Uninstall dev packages (no: other software need them)
#apt-get --assume-yes remove libgdal-dev libproj-dev libgeos-dev libgeos++-dev
apt-get --assume-yes autoremove

# make symlinks for geotifs to common data dir so all projects can use them
mkdir -p /usr/local/share/data/raster
cd /usr/local/share/data/raster
ln -s "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris .


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
