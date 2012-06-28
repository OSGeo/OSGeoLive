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

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
DATA_DIR="$USER_HOME/gisvm/app-data/eoxserver"
APACHE_CONF="/etc/apache2/conf.d/eoxserver"


#Install packages
apt-get update
apt-get --assume-yes install gcc libgdal1-1.7.0 libgdal1-dev python-gdal \
    libxml2 python-libxml2 sqlite libsqlite3-dev python-lxml python-pip \
    cgi-mapserver python-mapscript python2.7 python2.7-dev \
    libapache2-mod-wsgi libproj0 libproj-dev

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


# Install EOxServer
pip install --upgrade eoxserver


# Adjust pysqlite installation (without define=SQLITE_OMIT_LOAD_EXTENSION)
wget https://pysqlite.googlecode.com/files/pysqlite-2.6.3.tar.gz
tar xzf pysqlite-2.6.3.tar.gz
cd pysqlite-2.6.3
cat << EOF > setup.cfg
[build_ext]
libraries=sqlite3
EOF
python setup.py install --force
cd ..
rm pysqlite-2.6.3.tar.gz
rm -r pysqlite-2.6.3

# Install further dependencies
pip install --upgrade pyspatialite


# Create demonstration instance
[ -d $DATA_DIR ] || mkdir $DATA_DIR
cd $DATA_DIR
if [ ! -d eoxserver_demonstration ] ; then
    eoxserver-admin.py create_instance eoxserver_demonstration --init_spatialite
    cd eoxserver_demonstration
    python manage.py syncdb --noinput
    # Download and register demonstration data
    wget -c "http://eoxserver.org/export/1718/downloads/EOxServer_autotest-0.2.0.tar.gz" \
      -O EOxServer_autotest-0.2.0.tar.gz
    echo -n "Extracting demonstration data in `pwd`.\n"
    tar -xzf EOxServer_autotest-0.2.0.tar.gz
    mv EOxServer_autotest-0.2.0/data/fixtures/* data/fixtures/
    mkdir data/meris/
    mv EOxServer_autotest-0.2.0/data/meris/README data/meris/
    mkdir data/meris/mosaic_MER_FRS_1P_RGB_reduced/
    mv EOxServer_autotest-0.2.0/data/meris/mosaic_MER_FRS_1P_RGB_reduced/* data/meris/mosaic_MER_FRS_1P_RGB_reduced/
    rm EOxServer_autotest-0.2.0.tar.gz
    rm -r EOxServer_autotest-0.2.0/
    python manage.py loaddata auth_data.json initial_rangetypes.json testing_base.json testing_asar_base.json
    python manage.py eoxs_add_dataset_series --id MER_FRS_1P_RGB_reduced
    python manage.py eoxs_register_dataset \
        --data-files $DATA_DIR/eoxserver_demonstration/data/meris/mosaic_MER_FRS_1P_RGB_reduced/*.tif \
        --rangetype RGB --dataset-series MER_FRS_1P_RGB_reduced --visible=False
    touch logs/eoxserver.log
    chown www-data logs/eoxserver.log data/ data/config.sqlite
    sed -e 's/http_service_url=http:\/\/localhost:8000\/ows/http_service_url=http:\/\/localhost\/eoxserver\/ows/' -i conf/eoxserver.conf
    
fi


# Deploy instance in Apache2
if [ ! -e $DATA_DIR/eoxserver_demonstration/wsgi.py ] ; then
    cat << EOF > $DATA_DIR/eoxserver_demonstration/wsgi.py
import os
import sys
from django.core.handlers.wsgi import WSGIHandler
path = "$DATA_DIR/"
if path not in sys.path:
    sys.path.append(path)
os.environ["DJANGO_SETTINGS_MODULE"] = "eoxserver_demonstration.settings"
application = WSGIHandler()
EOF
fi

cat << EOF > $APACHE_CONF
Alias /media /usr/local/lib/python2.7/dist-packages/django/contrib/admin/media
Alias /static /usr/local/lib/python2.7/dist-packages/eoxserver/webclient/static
Alias /eoxserver "$DATA_DIR/eoxserver_demonstration/wsgi.py"

<Directory "$DATA_DIR/eoxserver_demonstration">
    AllowOverride None
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    AddHandler wsgi-script .py
    Order allow,deny
    allow from all
</Directory>
EOF
echo -n "Done\n"


# Add Launch icon to desktop
if [ ! -e /usr/share/applications/eoxserver.desktop ] ; then
   cat << EOF > /usr/share/applications/eoxserver.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=EOxServer
Comment=EOxServer
Categories=Application;Education;Geography;
Exec=firefox http://localhost/eoxserver/
Icon=gnome-globe
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi
cp /usr/share/applications/eoxserver.desktop "$USER_HOME/Desktop/"


# Reload Apache
/etc/init.d/apache2 force-reload


# Uninstall dev packages
#TODO
