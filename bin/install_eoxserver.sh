#!/bin/sh
# Copyright (c) 2012 Open Source Geospatial Foundation (OSGeo)
#
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
# This script installs EOxServer.

# Running:
# =======
# sudo ./install_eoxserver.sh

SCRIPT="install_eoxserver.sh"
echo "==============================================================="
echo "$SCRIPT"
echo "==============================================================="

echo "Starting EOxServer installation"

# Set EOxServer version to install
EOXSVER="0.3.0"

if [ -z "$USER_NAME" ] ; then
    USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
DATA_DIR="/usr/local/share/eoxserver"
DOC_DIR="$DATA_DIR/doc"
APACHE_CONF="/etc/apache2/conf.d/eoxserver"
TMP_DIR="/tmp/build_eoxserver"
POSTGRES_USER="$USER_NAME"


## check required tools are installed
if [ ! -x "`which wget`" ] ; then
    apt-get --assume-yes install wget
fi


#Install packages
apt-get -q update
apt-get --assume-yes install gcc libgdal1-dev python-gdal libxml2 python-lxml \
    python-libxml2 python-pip libproj0 libproj-dev libgeos-dev libgeos++-dev \
    cgi-mapserver python-mapscript libapache2-mod-wsgi python-psycopg2

if [ $? -ne 0 ] ; then
    echo 'ERROR: Package install failed! Aborting.'
    exit 1
fi


if [ ! -d "$TMP_DIR" ] ; then
    mkdir "$TMP_DIR"
fi
cd "$TMP_DIR"


# Install EOxServer
pip install --upgrade --no-deps eoxserver=="$EOXSVER"


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

    # Configure logging
    sed -e 's/#logging_level=/logging_level=INFO/' -i eoxserver_demonstration/conf/eoxserver.conf
    sed -e 's/DEBUG = True/DEBUG = False/' -i eoxserver_demonstration/settings.py

    # Further configuration
    echo "ALLOWED_HOSTS = ['localhost']" >> eoxserver_demonstration/settings.py

    # Initialize database
    python manage.py syncdb --noinput

    # Download and register demonstration data
    wget -c --progress=dot:mega \
       "http://eoxserver.org/export/head/downloads/EOxServer_autotest-$EOXSVER.tar.gz"

    echo "Extracting demonstration data in `pwd`."
    tar -xzf EOxServer_autotest-$EOXSVER.tar.gz
    chown -R root.root EOxServer_autotest-*

    mkdir -p eoxserver_demonstration/data/fixtures/
    mv EOxServer_autotest-$EOXSVER/data/fixtures/auth_data.json \
        EOxServer_autotest-$EOXSVER/data/fixtures/initial_rangetypes.json \
        eoxserver_demonstration/data/fixtures/

    mkdir -p eoxserver_demonstration/data/meris/
    mv EOxServer_autotest-$EOXSVER/data/meris/README \
        eoxserver_demonstration/data/meris/
    mv EOxServer_autotest-$EOXSVER/data/meris/mosaic_MER_FRS_1P_RGB_reduced/ \
        eoxserver_demonstration/data/meris/

    rm EOxServer_autotest-$EOXSVER.tar.gz
    rm -r EOxServer_autotest-$EOXSVER/

    python manage.py loaddata auth_data.json initial_rangetypes.json
    python manage.py eoxs_add_dataset_series --id MER_FRS_1P_RGB_reduced
    python manage.py eoxs_register_dataset \
        --data-files "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_RGB_reduced/*.tif \
        --rangetype RGB --dataset-series MER_FRS_1P_RGB_reduced --invisible

    touch eoxserver_demonstration/logs/eoxserver.log
    chown www-data eoxserver_demonstration/logs/eoxserver.log
    sed -e 's,http_service_url=http://localhost:8000/ows,http_service_url=http://localhost/eoxserver/ows,' \
        -i eoxserver_demonstration/conf/eoxserver.conf

    # Collect static files
    python manage.py collectstatic --noinput

    # Configure WSGI
    sed -e "s,^import os$,import os\nimport sys\n\npath = \"$DATA_DIR/eoxserver_demonstration/\"\nif path not in sys.path:\n    sys.path.append(path)\n," \
        -i eoxserver_demonstration/wsgi.py

    chmod g+w -R .
    chgrp users -R .
fi


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
    Order allow,deny
    allow from all
</Directory>
EOF
echo "Done"


# Install desktop icon
echo "Installing EOxServer icon"
if [ ! -e "/usr/share/icons/eoxserver_60x60.logo.png" ] ; then
    wget -c --progress=dot:mega \
        "http://eoxserver.org/export/head/trunk/osgeo-live/logo-eoxserver-3.png" \
        -O /usr/share/icons/eoxserver_60x60.logo.png
fi


# Add Launch icon to desktop
if [ ! -e /usr/share/applications/eoxserver.desktop ] ; then
    cat << EOF > /usr/share/applications/eoxserver.desktop
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

cp /usr/share/applications/eoxserver.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME.$USER_NAME "$USER_HOME/Desktop/eoxserver.desktop"


# EOxServer Documentation
echo "Getting EOxServer documentation"
[ -d "$DOC_DIR" ] || mkdir -p "$DOC_DIR"

cd "$DOC_DIR"
chmod g+w .
chgrp users .

wget -c --progress=dot:mega \
    "http://eoxserver.org/export/head/downloads/EOxServer_documentation-$EOXSVER.pdf" \
    -O EOxServer_documentation-$EOXSVER.pdf

ln -sf EOxServer_documentation-$EOXSVER.pdf EOxServer_documentation.pdf
chmod g+w -R EOxServer_documentation*
chgrp users -R EOxServer_documentation*
ln -sTf "$DOC_DIR" /var/www/eoxserver-docs

# Add Documentation Launch icon to desktop
if [ ! -e /usr/share/applications/eoxserver-docs.desktop ] ; then
    cat << EOF > /usr/share/applications/eoxserver-docs.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=EOxServer Documentation
Comment=EOxServer Documentation
Categories=Application;Geography;Geoscience;Education;
Exec=evince "$DOC_DIR/EOxServer_documentation.pdf"
Icon=/usr/share/icons/eoxserver_60x60.logo.png
Terminal=false
StartupNotify=false
EOF
fi
cp -a /usr/share/applications/eoxserver-docs.desktop "$USER_HOME/Desktop/"
chown -R $USER_NAME:$USER_NAME "$USER_HOME/Desktop/eoxserver-docs.desktop"


# Reload Apache
/etc/init.d/apache2 force-reload


# Uninstall dev packages
apt-get --assume-yes remove libgdal1-dev libproj-dev libgeos-dev libgeos++-dev
apt-get --assume-yes autoremove

# make symlinks for geotifs to common data dir so all projects can use them
mkdir -p /usr/local/share/data/raster
cd /usr/local/share/data/raster
ln -s "$DATA_DIR"/eoxserver_demonstration/eoxserver_demonstration/data/meris .

echo "==============================================================="
echo "Finished $SCRIPT"
echo Disk Usage1:, $SCRIPT, `df . -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, $SCRIPT, `df . -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
echo "==============================================================="
