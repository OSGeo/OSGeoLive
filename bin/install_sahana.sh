#! /bin/sh
#################################################
# 
# Purpose: Installation of Sahana Eden into Xubuntu
# Author:  Fran Boon, Rik Goldman, Steven Robinson, Jerel Moses, Maurice Quarles
#
#################################################
# Copyright (c) 2011 Open Source Geospatial Foundation (OSGeo)
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
##################################################

# About:
# =====
# This script will install Sahana Eden into Xubuntu

# Running:
# =======
# sudo ./install_sahana.sh

# Requires: Apache2, Python, PostgreSQL

#see also
# http://eden.sahanafoundation.org/wiki/InstallationGuidelinesLinux

# Check for Root User
gotroot=$(id -u)
if [ "$gotroot" != "0" ] ; then
	echo "This script must run with root privileges."
	exit 100
fi

# live disc's username is "user"
INSTALL_DIR="/usr/local/lib"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
SAHANA_CONF="/etc/apache2/conf.d/sahana"
BUILD_DIR="$USER_HOME/gisvm"
TMP_DIR="/tmp/build_sahana"
WEBSERVER="apache2"
# PostgreSQL
PG_VERSION="8.4"
# Geoserver
GS_VERSION="2.1.1"
GS_HOME="$INSTALL_DIR/geoserver-$GS_VERSION"

mkdir -p "$TMP_DIR"

# Update from repos
apt-get update
# Install dependencies and support tools
# Installed already by setup.sh
# wget make g++ bzip2
DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o DPkg::Options::=--force-confdef \
    -o DPkg::Options::=--force-confold \
    install \
	zlib1g-dev \
	libgeos-c1 \
	bzr \
	python2.6 \
	python-dev \
	ipython \
	python-lxml \
	python-dateutil \
	python-setuptools \
	python-shapely \
	python-imaging \
	python-reportlab \
	python-xlwt \
	libapache2-mod-wsgi \
	postgresql-8.4 \
	python-psycopg2

# Install python-tweepy
echo "deb http://ppa.launchpad.net/chris-lea/python-tweepy/ubuntu lucid main
deb-src http://ppa.launchpad.net/chris-lea/python-tweepy/ubuntu lucid main" \
   > /etc/apt/sources.list.d/python-tweepy.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
apt-get update
apt-get install --yes python-tweepy

# Install PostGIS 1.5
# should be done already by install_postgis.sh
#wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_0/sources.list.d/ubuntugis.list \
#     --output-document=/etc/apt/sources.list.d/ubuntugis.list
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  
#apt-get update
#apt-get install --yes "postgresql-$PG_VERSION-postgis" postgis

# Download and Install Geraldo
#wget -c --progress=dot:mega \
#   "http://pypi.python.org/packages/source/G/Geraldo/Geraldo-0.4.10-stable.tar.gz" \
#   -O "$TMP_DIR/Geraldo-0.4.10-stable.tar.gz"
#tar xzf "$TMP_DIR"/Geraldo-0.4.10-stable.tar.gz -C "$TMP_DIR"
#cd "$TMP_DIR"/Geraldo-0.4.10-stable
#python setup.py install

# Add DB User
su -c - postgres "createuser -s sahana" && true
# Create Fresh DB
# ensure no active connections to old one
#apache2ctl stop # WSGI
killall python
su -c - postgres "dropdb sahana" && true
su -c - postgres "createdb -O sahana sahana"
su -c - postgres "createlang plpgsql -d sahana"

# Add Role Password
cat << EOF > "$TMP_DIR/sahana.sql"
ALTER ROLE sahana WITH PASSWORD 'sahana';
EOF
su -c - postgres "psql -q -d sahana -f $TMP_DIR/sahana.sql"

# Import GIS template
su -c - postgres "psql -q -d sahana -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql"
su -c - postgres "psql -q -d sahana -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql"

# Add web2py account
# - with mod_proxy we now run web2py as 'user'
#adduser --system --disabled-password --no-create-home web2py && true
#addgroup web2py && true
#usermod -G web2py web2py && true

# Download web2py
rm -rf "$INSTALL_DIR"/web2py
#bzr checkout --lightweight -r 2922 lp:~mdipierro/web2py/devel "$INSTALL_DIR"/web2py 
wget -c --progress=dot:mega \
   "http://eden.sahanafoundation.org/downloads/web2py_src-1.98.2.zip" \
   -O "$TMP_DIR/web2py_src-1.98.2.zip"
unzip -q "$TMP_DIR"/web2py_src-1.98.2.zip -d "$INSTALL_DIR"
#cp "$INSTALL_DIR"/web2py/routes.example.py "$INSTALL_DIR"/web2py/routes.py

if [ ! -f "$INSTALL_DIR/web2py/routes.py" ] ; then
	cp "$INSTALL_DIR/web2py/routes.example.py" "$INSTALL_DIR/web2py/routes.py"
fi
cat << EOF >> "$INSTALL_DIR/web2py/routes.py"

routes_onerror = [
        ('eden/401', '/eden/default/user/login'),
        ('eden/*', '/eden/errors/index'),
        ('*/*', '/eden/errors/index'),
    ]
EOF

# Install Sahana Eden 0.5.5
bzr checkout --lightweight -r2689 lp:sahana-eden \
   "$INSTALL_DIR/web2py/applications/eden"

# Create Eden Directories
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/gis_cache"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/images"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/uploads/tracks"
mkdir -p "$INSTALL_DIR/web2py/applications/eden/admin/cache"

# Set permissions
mkdir -p "$INSTALL_DIR/web2py/applications/admin/databases"
mkdir -p "$INSTALL_DIR/web2py/applications/admin/errors"
mkdir -p "$INSTALL_DIR/web2py/applications/admin/sessions"
chown "$USER_NAME" \
	"$INSTALL_DIR/web2py/applications/admin/cache" \
	"$INSTALL_DIR/web2py" \
	"$INSTALL_DIR/web2py/applications/admin/cron" \
	"$INSTALL_DIR/web2py/applications/admin/databases" \
	"$INSTALL_DIR/web2py/applications/admin/errors" \
	"$INSTALL_DIR/web2py/applications/admin/sessions" \
	"$INSTALL_DIR/web2py/applications/eden" \
	"$INSTALL_DIR/web2py/applications/eden/cache" \
	"$INSTALL_DIR/web2py/applications/eden/cron" \
	"$INSTALL_DIR/web2py/applications/eden/databases" \
	"$INSTALL_DIR/web2py/applications/eden/errors" \
	"$INSTALL_DIR/web2py/applications/eden/models" \
	"$INSTALL_DIR/web2py/applications/eden/sessions" \
	"$INSTALL_DIR/web2py/applications/eden/static/img/markers" \
	"$INSTALL_DIR/web2py/applications/eden/uploads" \
	"$INSTALL_DIR/web2py/applications/eden/uploads/gis_cache" \
	"$INSTALL_DIR/web2py/applications/eden/uploads/images" \
	"$INSTALL_DIR/web2py/applications/eden/uploads/tracks"

# Copy Deployment Templates
if [ ! -f "$INSTALL_DIR/web2py/applications/eden/models" ] ; then
	cp "$INSTALL_DIR/web2py/applications/eden/deployment-templates/models/000_config.py" \
	   "$INSTALL_DIR/web2py/applications/eden/models"
fi

if [ ! -f "$INSTALL_DIR/web2py/applications/eden/cron/crontab" ] ; then
	cp "$INSTALL_DIR/web2py/applications/eden/deployment-templates/cron/crontab" \
	   "$INSTALL_DIR/web2py/applications/eden/cron/crontab"
fi

# Stream Edit 000_config.py
sed -i 's|EDITING_CONFIG_FILE = False|EDITING_CONFIG_FILE = True|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|127.0.0.1:8000|127.0.0.1|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|deployment_settings.gis.spatialdb = False|deployment_settings.gis.spatialdb = True|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
# Denver FOSS4G
sed -i 's|deployment_settings.L10n.utc_offset = "UTC +0000"|deployment_settings.L10n.utc_offset = "UTC -0700"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Stream Edit 000_config.py for Postgres Database
sed -i 's|database.db_type = "sqlite"|database.db_type = "postgres"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|database.password = "password"|database.password = "sahana"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Configure Eden for Denver (FOSS4G 2011)
sed -i 's|lat = "22.593723263"|lat = "39.739167"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|lon = "5.28516253"|lon = "-104.984722"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|zoom = 2|zoom = 10|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

cat << EOF >> "$INSTALL_DIR/web2py/applications/eden/models/zzz_1st_run.py"
    # Create Login
    table = auth.settings.table_user_name
    # 1st-run initialisation
    if not len(db().select(db[table].ALL)):
        import hmac
        import hashlib
        alg = hashlib.sha512
        db[table].insert(
            email = 'admin',
            password = hmac.new(auth.settings.hmac_key, 'admin', alg).hexdigest(),
            utc_offset = '-0700',
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
sed -i 's|wmsbrowser_url = "http://geo.eden.sahanafoundation.org/geoserver/wms?service=WMS&request=GetCapabilities"|wmsbrowser_url = "http://localhost:8082/geoserver/wms?service=WMS\&request=GetCapabilities"|' \
   "$INSTALL_DIR/web2py/applications/eden/models/zzz_1st_run.py"

# Perform the initial database Migration/Prepopulation 
cd "$INSTALL_DIR/web2py"
touch NEWINSTALL
sudo -H -u "$USER_NAME" python web2py.py -S eden -M \
   -R applications/eden/static/scripts/tools/noop.py

# Stream Edit 000_config.py to disable migration
sed -i 's|deployment_settings.base.migrate = True|deployment_settings.base.migrate = False|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"
sed -i 's|deployment_settings.base.prepopulate = 1|deployment_settings.base.prepopulate = 0|' \
   "$INSTALL_DIR/web2py/applications/eden/models/000_config.py"

# Compile scripts to optimise performance
cd "$INSTALL_DIR/web2py"
chown "$USER_NAME" .
sudo -H -u "$USER_NAME" python web2py.py -S eden -M \
   -R applications/eden/static/scripts/tools/compile.py

# Prepare to Add Geometry Column
#   (from http://eden.sahanafoundation.org/wiki/InstallationGuidelinesPostgreSQL#AddGeometrycolumntogis_location)
cat << EOF > "$TMP_DIR/geometry.sql"
UPDATE public.gis_location SET wkt = 'POINT (' || lon || ' ' || lat || ')' WHERE gis_feature_type = 1;
SELECT AddGeometryColumn( 'public', 'gis_location', 'the_geom', 4326, 'GEOMETRY', 2 );
UPDATE public.gis_location SET the_geom = ST_SetSRID(ST_GeomFromText(wkt), 4326);
EOF
# Add Geometry Column
if [ -e "$TMP_DIR/geometry.sql" ] ; then
    su -c - postgres "psql -q -d sahana -f '$TMP_DIR'/geometry.sql"
fi

# AutoPopulate (from http://eden.sahanafoundation.org/wiki/InstallationGuidelinesPostgreSQL#AddGeometrycolumntogis_location)
cat << EOF > "$TMP_DIR/autopopulate.sql"
CREATE OR REPLACE FUNCTION s3_update_geometry()
  RETURNS "trigger" AS \$$
  DECLARE
  BEGIN
    if (NEW.wkt != '') then
        NEW.the_geom = SetSRID(GeomFromText(NEW.wkt), 4326);
        end if;

    RETURN NEW;
  END;
\$$  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION s3_update_geometry() OWNER TO sahana;
CREATE TRIGGER s3_locations_update
  BEFORE INSERT
  ON gis_location
  FOR EACH ROW
  EXECUTE PROCEDURE s3_update_geometry();

EOF
# Import Autopopulate
if [ -e "$TMP_DIR/autopopulate.sql" ]; then
    su -c - postgres "psql -q -d sahana -f '$TMP_DIR'/autopopulate.sql"
fi


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
     ProxyPass http://localhost:8000/eden
     ProxyPassReverse http://localhost:8000/
     #ProxyHTMLURLMap http://127.0.0.1:8000/eden/ /eden
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
python web2py.py -a admin &
DELAY=40
(
for TIME in \`seq \$DELAY\` ; do
  sleep 1
  echo "\$TIME \$DELAY" | awk '{print int(0.5+100*\$1/\$2)}'
done
) | zenity --progress --auto-close --text "Sahana starting"
zenity --info --text "Starting web browser ..."
firefox "http://localhost:8000/eden"
EOF

chmod +x "$START_SCRIPT"

# Add Launch icon to desktop
cp "$BUILD_DIR"/app-conf/sahana/sahana.png /usr/share/icons/

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
cp -f /usr/share/applications/sahana.desktop "$USER_HOME/Desktop/sahana.desktop"
