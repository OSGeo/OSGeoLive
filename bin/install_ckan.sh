#!/bin/sh
# Copyright (c) 2015 Open Source Geospatial Foundation (OSGeo)
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
# This script installs CKAN.

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

CKAN_HOME="/var/local/ckan/default"
PYENV_DIR="/var/local/ckan/default/pyenv"
PYENV_BIN="/var/local/ckan/default/pyenv/bin"
PYENV_SRC="/var/local/ckan/default/pyenv/src"

mkdir -p "$CKAN_HOME"


echo "Installing needed packages"

apt-get -q update
apt-get --assume-yes install python python-virtualenv python-setuptools python-dev python-psycopg2 libpq-dev libxml2-dev libxslt1-dev tidy libtidy-dev unzip p7zip-full python-gdal


echo "Installing PostgreSQL databases"

sudo -u "$USER_NAME" createuser ckaner
sudo -u "$USER_NAME" psql -c "ALTER USER ckaner WITH PASSWORD 'ckaner';"
sudo -u "$USER_NAME" createuser ckan_datastorer
sudo -u "$USER_NAME" psql -c "ALTER USER ckan_datastorer WITH PASSWORD 'ckan_datastorer';"
sudo -u "$USER_NAME" createdb -E UTF8 -O ckaner ckan
sudo -u "$USER_NAME" createdb -E UTF8 -O ckan_datastorer ckan_data


echo "Installing PostGIS extension"

sudo -u "$USER_NAME" psql -d ckan -c 'CREATE EXTENSION "postgis";'
sudo -u "$USER_NAME" psql -d ckan_data -c 'CREATE EXTENSION "postgis";'


echo "Installing CKAN core"

cd "$CKAN_HOME"
mkdir -p "$CKAN_HOME/log" "$CKAN_HOME/run" "$CKAN_HOME/tmp" "$CKAN_HOME/files/resources" "$CKAN_HOME/files/storage"
virtualenv --setuptools "$PYENV_DIR"
mkdir -p "$PYENV_SRC"
cd "$PYENV_BIN"
./pip install --upgrade pip
# "$PYENV_BIN"/pip install --upgrade pip

chown -R "$USER_NAME":"$USER_NAME" "$CKAN_HOME"
chown -R www-data:www-data "$CKAN_HOME/tmp"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/ckan.git 
../bin/pip install -r "$PYENV_SRC/ckan/requirements.txt"
cd ckan
../../bin/python setup.py develop


echo "Installing ckanext-archiver"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/ckanext-archiver.git
../bin/pip install -r "$PYENV_SRC/ckanext-archiver/pip-requirements.txt"
cd ckanext-archiver
../../bin/python setup.py develop


echo "Installing ckanext-datastorer"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/ckanext-datastorer.git
../bin/pip install -r "$PYENV_SRC/ckanext-datastorer/pip-requirements.txt"
cd ckanext-datastorer
../../bin/python setup.py develop


echo "Installing ckanext-spatial"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/ckanext-spatial.git
../bin/pip install -r "$PYENV_SRC/ckanext-spatial/pip-requirements.txt"
cd ckanext-spatial
../../bin/python setup.py develop


echo "Installing pycsw"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/pycsw.git
../bin/pip install geolinks
../bin/pip install pyproj
cd pycsw
../../bin/python setup.py build
../../bin/python setup.py install
rm csw.wsgi
cp "$BUILD_DIR/../app-conf/ckan/csw.wsgi" ./
cp "$BUILD_DIR/../app-conf/ckan/default.cfg" ./
chmod 755 csw.wsgi


echo "Installing ckanext-publicamundi"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/ckanext-publicamundi.git
../bin/pip install -r "$PYENV_SRC/ckanext-publicamundi/requirements.txt"
../bin/pip install -r "$PYENV_SRC/ckanext-publicamundi/vectorstorer-requirements.txt"
cd ckanext-publicamundi
../../bin/python setup.py develop


echo "Installing Publicamundi APIs"

cd "$PYENV_SRC"
git clone -b dev.publicamundi.eu https://github.com/PublicaMundi/MapClient.git mapclient
cd "$PYENV_SRC/mapclient"
../../bin/python setup.py build
../../bin/python setup.py install
cp "$BUILD_DIR/../app-conf/ckan/map-development.ini" ./development.ini
ln -s development.ini config.ini


echo "CKAN configuration"

touch "$PYENV_DIR/src/ckanext-publicamundi/ckanext/publicamundi/public/js/scratch.js"
cd "$PYENV_SRC/ckan"
cp "$BUILD_DIR/../app-conf/ckan/development.ini" ./
../../bin/paster db init -c development.ini
../../bin/paster datastore set-permissions postgres -c development.ini
cd "$PYENV_SRC/ckanext-publicamundi"
../../bin/paster publicamundi-setup -c "$PYENV_SRC/ckan/development.ini"

chown -R www-data:www-data "$CKAN_HOME/files/storage"
chmod 755 "$CKAN_HOME/files/storage"
chown -R www-data:www-data "$CKAN_HOME/files/resources"
chmod 755 "$CKAN_HOME/files/resources"
cp "$BUILD_DIR/../app-conf/ckan/default" /etc/apache2/sites-available/
cd "$PYENV_SRC/ckan"
ln -s development.ini config.ini
../../bin/paster user -c config.ini add admin password=admin email=admin@example.com
../../bin/paster sysadmin -c config.ini add admin

service apache2 restart

####
./diskspace_probe.sh "`basename $0`" end
