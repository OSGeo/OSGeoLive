#! /bin/sh
#################################################
#
# Purpose: Installation of Sahana Eden into Xubuntu
# Author:  Fran Boon, Rik Goldman, Steven Robinson, Jerel Moses, Maurice Quarles
#
# Copyright (c) 2011-2016 Open Source Geospatial Foundation (OSGeo)
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
##################################################
#
# About:
# =====
# This script will install Sahana Eden into Xubuntu
#
# Requires: Apache2, Python, PostgreSQL
#
# see also
#  http://eden.sahanafoundation.org/wiki/InstallationGuidelinesLinux


./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# Check for Root User
gotroot=$(id -u)
if [ "$gotroot" != "0" ] ; then
   echo "This script must run with root privileges."
   exit 100
fi

# live disc's username is "user"
INSTALL_DIR="/usr/local/lib"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

SAHANA_CONF="/etc/apache2/conf-available/sahana.conf"
TMP_DIR="/tmp/build_sahana"
WEBSERVER="apache2"

## versions syncd manually
# PostgreSQL
PG_VERSION="9.5"
# Geoserver
GS_VERSION="2.15.1"
GS_HOME="$INSTALL_DIR/geoserver-$GS_VERSION"

# FIXME: Script doesn't currently use this var
PORT="8007"

mkdir -p "$TMP_DIR"

# Update from repos
apt-get -q update
# Install dependencies and support tools
# Installed already by setup.sh
# wget make g++ bzip2
DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o DPkg::Options::=--force-confdef \
    -o DPkg::Options::=--force-confold \
    install \
	git \
	unzip \
	zlib1g-dev \
	libgeos-c1v5 \
	python-dev \
	python-lxml \
	python-dateutil \
	python-shapely \
	python-imaging \
	python-reportlab \
	python-xlrd \
	python-xlwt \
	python-numpy \
	libapache2-mod-wsgi \
	python-psycopg2

## 09feb14  do not install python-matplotlib
##  pip install version is newer.. more pip wars
##  TODO even more defensive scripting

if [ ! -e /usr/share/pyshared/matplotlib ] ; then
    apt-get install -y python-matplotlib
    #pip install matplotlib
fi

# Install python-tweepy (optional)
##echo "deb http://ppa.launchpad.net/chris-lea/python-tweepy/ubuntu precise main
##deb-src http://ppa.launchpad.net/chris-lea/python-tweepy/ubuntu precise main" \
##   > /etc/apt/sources.list.d/python-tweepy.list
##apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
##apt-get -q update
##apt-get install --yes python-tweepy

# Install PostGIS 2.2  done elsewhere
#apt-get install --yes "postgresql-$PG_VERSION-postgis" postgis libgdal1

# Add DB User
su -c - postgres "createuser -s sahana" && true
# Create Fresh DB
# ensure no active connections to old one
#apache2ctl stop # WSGI
killall python
su -c - postgres "dropdb sahana" && true
su -c - postgres "createdb -E UTF8 -O sahana sahana"
# Not needed any more
#su -c - postgres "createlang plpgsql -d sahana"

# Add Role Password
cat << EOF > "$TMP_DIR/sahana.sql"
ALTER ROLE sahana WITH PASSWORD 'sahana';
EOF
su -c - postgres "psql -q -d sahana -f $TMP_DIR/sahana.sql"

# Create db with postgis extensions
su -c - postgres "psql -q -d sahana -c 'create extension postgis'"

# Add web2py account
# - with mod_proxy we now run web2py as 'user'
#adduser --system --disabled-password --no-create-home web2py && true
#addgroup web2py && true
#usermod -G web2py web2py && true

# Download web2py
rm -rf "$INSTALL_DIR"/web2py
#W2P_FILE="web2py_src-1.99.7.zip"
#wget -c --progress=dot:mega \
#   "http://eden.sahanafoundation.org/downloads/$W2P_FILE" \
#   -O "$TMP_DIR/$W2P_FILE"
#unzip -q "$TMP_DIR/$W2P_FILE" -d "$INSTALL_DIR"
cd "$INSTALL_DIR"
git clone git://github.com/web2py/web2py.git
cd web2py
git checkout 354e63d0fea30e35b7d55f4f26dd34b4d887232f
#git checkout 828a4d7a60021b20bd9dfacf8235e9113156271b
git reset --hard

cat << EOF > "$INSTALL_DIR/web2py/routes.py"
default_application = 'eden'
default_controller = 'default'
default_function = 'index'
routes_onerror = [
        ('eden/400', '!'),
        ('eden/401', '!'),
        ('eden/*', '/eden/errors/index'),
        ('*/*', '/eden/errors/index'),
    ]
EOF

# Install Sahana Eden
cd "$INSTALL_DIR/web2py/applications"
git clone git://github.com/flavour/eden.git
cd eden
git checkout deca684114b572b1965521cf7d28afd76cdd9fc6
git reset --hard

# Create Eden Directories
mkdir -p "$INSTALL_DIR/web2py/applications/eden/cache"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/databases"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/errors"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/sessions"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/gis_cache"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/images"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/tracks"

# Set permissions
mkdir -p "$INSTALL_DIR/web2py/applications/admin/cache"
mkdir -p "$INSTALL_DIR/web2py/applications/admin/databases"
mkdir -p "$INSTALL_DIR/web2py/applications/admin/errors"
mkdir -p "$INSTALL_DIR/web2py/applications/admin/sessions"

FILES="
   $INSTALL_DIR/web2py/applications/admin/cache
   $INSTALL_DIR/web2py
   $INSTALL_DIR/web2py/applications/admin/cron
   $INSTALL_DIR/web2py/applications/admin/databases
   $INSTALL_DIR/web2py/applications/admin/errors
   $INSTALL_DIR/web2py/applications/admin/sessions
   $INSTALL_DIR/web2py/applications/eden
   $INSTALL_DIR/web2py/applications/eden/cache
   $INSTALL_DIR/web2py/applications/eden/cron
   $INSTALL_DIR/web2py/applications/eden/databases
   $INSTALL_DIR/web2py/applications/eden/errors
   $INSTALL_DIR/web2py/applications/eden/models
   $INSTALL_DIR/web2py/applications/eden/sessions
   $INSTALL_DIR/web2py/applications/eden/static/img/markers
   $INSTALL_DIR/web2py/applications/eden/uploads
   $INSTALL_DIR/web2py/applications/eden/uploads/gis_cache
   $INSTALL_DIR/web2py/applications/eden/uploads/images
   $INSTALL_DIR/web2py/applications/eden/uploads/tracks
"
chgrp users $FILES
chmod g+w $FILES
adduser "$USER_NAME" users


# Copy Deployment Templates
if [ ! -f "$INSTALL_DIR/web2py/applications/eden/models" ] ; then
	cp "$INSTALL_DIR/web2py/applications/eden/private/templates/000_config.py" \
	   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
fi

# Stream Edit 000_config.py
sed -i 's|EDITING_CONFIG_FILE = False|EDITING_CONFIG_FILE = True|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|#settings.base.public_url = "http://127.0.0.1:8000"|settings.base.public_url = "http://127.0.0.1"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
# Not working with PostGIS 2 (prepop fails)
#sed -i 's|#settings.gis.spatialdb = True|settings.gis.spatialdb = True|' \
#   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Stream Edit 000_config.py for Postgres Database
sed -i 's|#settings.database.db_type = "postgres"|settings.database.db_type = "postgres"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|#settings.database.password = "password"|settings.database.password = "sahana"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Configure Eden for Portland (FOSS4G 2014)
sed -i -e 's|22.593723263|45.5282|' \
       -e 's|5.28516253|-122.6632|' \
       -e 's|,2,|,12,|' \
   "$INSTALL_DIR/web2py/applications/eden/private/templates/default/gis_config.csv"

#sed -i 's|#settings.L10n.utc_offset = "UTC +0000"|settings.L10n.utc_offset = "UTC +0100"|' \
#   "$INSTALL_DIR/web2py/applications/eden/private/templates/default/config.py"

cat << EOF >> "$INSTALL_DIR/web2py/applications/eden/models/zzz_1st_run.py"
    # Create Login
    table = auth.settings.table_user_name
    # 1st-run initialisation
    if not len(db().select(db[table].id, limitby=(0, 1))):
        import hmac
        import hashlib
        alg = hashlib.sha512
        db[table].insert(
            email = 'admin',
            password = hmac.new(auth.settings.hmac_key, 'admin', alg).hexdigest(),
            utc_offset = '+0800',
            first_name = 'Admin',
            last_name = 'User'
        )
    db.commit()
    # Add user to admin role
    auth.add_membership(1, 1)
    # Add user to authenticated role
    auth.add_membership(2, 1)
    db.commit()
EOF

# Configure Eden to make use of local GeoData
sed -i 's|-180,180,"|-180,180,"http://localhost:8082/geoserver/wms?service=WMS\&request=GetCapabilities"|' \
   "$INSTALL_DIR/web2py/applications/eden/private/templates/default/gis_config.csv"

# Perform the initial database Migration/Prepopulation 
cd "$INSTALL_DIR/web2py"
touch NEWINSTALL

sudo -H -u "$USER_NAME" python web2py.py -S eden -M \
   -R applications/eden/static/scripts/tools/noop.py

# Stream Edit 000_config.py to disable migration
sed -i 's|settings.base.migrate = True|settings.base.migrate = False|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|#settings.base.prepopulate = 0|settings.base.prepopulate = 0|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Compile scripts to optimise performance
cd "$INSTALL_DIR/web2py"
chgrp users "$INSTALL_DIR/web2py"
chmod g+w "$INSTALL_DIR/web2py"

sudo -H -u "$USER_NAME" python web2py.py -S eden -M \
   -R applications/eden/static/scripts/tools/compile.py

# final tidy up
su -c - postgres "psql -d sahana -c 'VACUUM ANALYZE'"


chown root.root "$INSTALL_DIR"/web2py/applications/eden/compiled/ -R
chown root.root "$INSTALL_DIR"/web2py/applications/eden/__init__.pyc

# not sure which of the rest need to be writable by the user, so make them all
chown root.users "$INSTALL_DIR"/web2py/applications/eden/databases/*
chmod g+w "$INSTALL_DIR"/web2py/applications/eden/databases/*
chown root.users "$INSTALL_DIR"/web2py/applications/eden/cache/*
chmod g+w "$INSTALL_DIR"/web2py/applications/eden/cache/*
chown root.users "$INSTALL_DIR"/web2py/deposit "$INSTALL_DIR"/web2py/logs
chmod g+w "$INSTALL_DIR"/web2py/deposit "$INSTALL_DIR"/web2py/logs

# does it really need to be writable?
chown root.users "$INSTALL_DIR"/web2py/welcome.w2p
chmod g+w "$INSTALL_DIR"/web2py/welcome.w2p
# does it really need to be writable?
chown root.users "$INSTALL_DIR"/web2py/applications/eden/models/0000_update*.py
chmod g+w "$INSTALL_DIR"/web2py/applications/eden/models/0000_update*.py


# Apache configuration
# Enable Modules
#a2enmod ssl
#a2enmod rewrite
#a2enmod wsgi
a2enmod proxy
a2enmod proxy_http

#Create Sahana Conf for Apache2
cat << EOF > "$SAHANA_CONF"
  Alias /eden/static /usr/local/lib/web2py/applications/eden/static
  ProxyRequests off
  #WSGIScriptAlias /eden/ /usr/local/lib/web2py/wsgihandler.py
  #WSGIDaemonProcess web2py user=web2py group=web2py home=/usr/local/lib/web2py maximum-requests=1000
  # serve static files directly
  <Directory /usr/local/lib/web2py/applications/eden/static/>
    Order Allow,Deny
    Allow from all
  </Directory>
  # proxy all the other requests
  <Location "/eden">
     Order deny,allow
     Allow from all
     ProxyPass http://localhost:8007/eden
     ProxyPassReverse http://localhost:8007/
     #ProxyHTMLURLMap http://127.0.0.1:8007/eden/ /eden
  </Location>
  # everything else goes over WSGI (but this doesn't work on a subfolder)
  #<Directory /usr/local/lib/web2py>
  #  AllowOverride None
  #  Order Allow,Deny
  #  Deny from all
  #  <Files wsgihandler.py>
  #    Allow from all
  #  </Files>
  #</Directory>
  #<Location "/eden">
  #  Order deny,allow
  #  Allow from all
  #  WSGIProcessGroup web2py
  #</Location>
EOF

a2enconf sahana.conf

# Restart Apache2
apache2ctl restart

# Create startup script
START_SCRIPT="/usr/local/bin/start_sahana.sh"
cat << EOF > "$START_SCRIPT"
#!/bin/sh
EOF
# Start Geoserver, since we can make use of it
echo "$GS_HOME/bin/startup.sh &" >> "$START_SCRIPT"
echo "cd $INSTALL_DIR/web2py" >> "$START_SCRIPT"
cat << EOF >> "$START_SCRIPT"
python web2py.py -a admin -p 8007 &
DELAY=40
(
for TIME in \`seq \$DELAY\` ; do
  sleep 1
  echo "\$TIME \$DELAY" | awk '{print int(0.5+100*\$1/\$2)}'
done
) | zenity --progress --auto-close --text "Sahana starting"
zenity --info --text "Starting web browser ..."
firefox "http://localhost:8007/eden"
EOF

chmod +x "$START_SCRIPT"

# Add Launch icon to desktop
chmod 644 "$BUILD_DIR"/../app-conf/sahana/sahana.png
cp "$BUILD_DIR"/../app-conf/sahana/sahana.png /usr/share/icons/

cat << EOF > /usr/share/applications/sahana.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Sahana
Comment=Sahana Eden
Categories=Application;Internet;
Exec=/usr/local/bin/start_sahana.sh
Icon=/usr/share/icons/sahana.png
Terminal=false
StartupNotify=false
EOF

# Prepare Desktop
mkdir -p "$USER_HOME/Desktop"
cp -f /usr/share/applications/sahana.desktop \
   "$USER_HOME/Desktop/sahana.desktop"

# cleanup, but do not remove python-dev here
# apt-get --assume-yes remove python-dev

rm -rf "$INSTALL_DIR/web2py/.git"*
rm -rf "$INSTALL_DIR/web2py/applications/eden/.git"*


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
