#!/bin/bash

# Copyright (c) 2012 geOps (www.geops.de) 
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
#
# About:
# =====
# This script will install Cartaro
#
# Running:
# =======
# sudo ./install_cartaro.sh
#
# Depedencies:
# ===========
# Needs already installed Geoserver with Version 2.2
#

echo "==============================================================="
echo "starting install_cartaro.sh"
echo "==============================================================="


CARTARO_PASSWORD="geoserver"
CARTARO_USER="cartaro-admin"

CARTARO_VERSION="1.0-beta3"

DB_NAME="cartaro"
DB_USER="cartaro"
DB_PASSWORD="cartaro"

GEO_ADMIN="admin"
GEO_PASS="geoserver"
GEO_PATH="/usr/local/lib/geoserver-2.2"

TMP_DIR="/tmp/build_cartaro"
TARGET_DIR="/usr/local/lib/cartaro"
DOC_DIR="/usr/local/share/cartaro"
GEOSERVER_URL="http://localhost:8082/geoserver"
POSTGIS_PATH="/usr/share/postgresql/9.1/contrib"

if [ -z "$USER_NAME" ] ; then
       USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

DOC_DIR="$TARGET_DIR/doc"

##############################
# Ensure all Packages are installed
#############################

echo "[install_cartaro.sh] Installing Packages..."

PACKAGES="wget unzip apache2 php5 php5-gd php5-curl php5-pgsql postgresql \
postgis postgresql-9.1-postgis postgresql-contrib-9.1"

echo "Installing: $PACKAGES"
apt-get --assume-yes install $PACKAGES
if [ $? -ne 0 ] ; then
    echo "ERROR: package install failed"
    exit 1
fi

##############################
# Prepare folders
##############################

if [ ! -d "${TMP_DIR}" ]; then
	mkdir -p ${TMP_DIR}
fi 

###############################
# Prepare Database 
###############################

echo "[install_cartaro.sh] Prepare Database ..."

#ensure all database conntections to db for cartaro are closed
/etc/init.d/apache2 stop
/etc/init.d/postgresql restart

/bin/su postgres -c " /usr/bin/psql  -c \" drop database  ${DB_NAME};  \""
/bin/su postgres -c " /usr/bin/psql  -c \" drop role  ${DB_NAME};  \""

/bin/su postgres -c " /usr/bin/psql  -c \" create role  ${DB_USER} with login password '${DB_PASSWORD}';  \""
/bin/su postgres -c "/usr/bin/createdb -O ${DB_USER} -E UTF-8 ${DB_NAME}"

/etc/init.d/apache2 start

###############################
# Prepare PostGIS 
###############################

echo "[install_cartaro.sh] Prepare PostGIS ..."

/bin/su postgres -c "/usr/bin/psql -1 -d ${DB_NAME} -f ${POSTGIS_PATH}/postgis-2.0/postgis.sql"
/bin/su postgres -c "/usr/bin/psql -1 -d ${DB_NAME} -f ${POSTGIS_PATH}/postgis-2.0/spatial_ref_sys.sql"
/bin/su postgres -c "/usr/bin/psql -1 -d ${DB_NAME}  -f ${POSTGIS_PATH}/postgis_comments.sql"
/bin/su postgres -c "/usr/bin/psql -d ${DB_NAME}  -c \" grant all on geometry_columns to ${DB_USER}; grant all on spatial_ref_sys to ${DB_USER}; \""

#####################
# Install Drush
#####################


echo "[install_cartaro.sh] Install Drush ..."

# install a working version of drush and patch it to not drop
# all tables, as this will also drop to postgis table

# install only, if folder does not already exists
DRUSH_DIR=$TARGET_DIR/drush
DRUSH_FILE="drush-7.x-5.4.tar.gz"

if [ ! -f "$DRUSH_DIR/drush" ]; then
    	mkdir -p $DRUSH_DIR 
	if [ ! -f "${TMP_DIR}/${DRUSH_FILE}" ]; then
        	pushd "$TMP_DIR"
		wget http://ftp.drupal.org/files/projects/drush-7.x-5.4.tar.gz
		popd
        fi
    	pushd "$TARGET_DIR"
        # remove table dropping
	tar xzf "$TMP_DIR/$DRUSH_FILE"
        sed -ri "s/'DROP TABLE '/\'-- DROP TABLE \'/g" "$DRUSH_DIR/commands/sql/sql.drush.inc"
    popd
fi

#####################
# Download Cartaro
#####################

echo "[install_cartaro.sh] Download Cartaro ..."


if [ -d "$TARGET_DIR" ]; then
    find "$TARGET_DIR" -type d -exec chmod u+wx {} \;
fi

CARTARO_FILE="cartaro-7.x-${CARTARO_VERSION}-core.tar.gz"

if [ ! -d "$TARGET_DIR/cartaro-7.x-$CARTARO_VERSION" ]; then
	if [ ! -f "$TMP_DIR/$CARTARO_FILE" ]; then
		pushd "$TMP_DIR"
		/usr/bin/wget -c "http://ftp.drupal.org/files/projects/cartaro-7.x-${CARTARO_VERSION}-core.tar.gz"
		popd
	fi    	
	pushd "$TARGET_DIR"
	/bin/tar xzf "$TMP_DIR/$CARTARO_FILE"
	/bin/mv cartaro-7.x-${CARTARO_VERSION}/* .
    
    # save filespace

    rm -Rf profiles/cartaro/libraries/openlayers/doc

    popd


fi

###################
# Configure apache
##################

echo "[install_cartaro.sh] Configure Apache2  ..."


if [ ! -f /etc/apache2/conf.d/cartaro ]; then

cat << EOF > /etc/apache2/conf.d/cartaro
<Directory /var/www/cartaro>
	RewriteEngine On
	RewriteRule "(^|/)\." - [F]
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteCond %{REQUEST_URI} !=/favicon.ico
	RewriteRule ^ /cartaro/index.php [L]
</Directory>
EOF
/etc/init.d/apache2 reload
fi

####################
# Install Cartaro 
###################

#ensure geoserver is running

echo "[install_cartaro.sh] Install Cartaro ..."


${GEO_PATH}/bin/shutdown.sh &
sleep 60;
${GEO_PATH}/bin/startup.sh &
sleep 60;


# attempt to run a site-install and reenter the password a few times
pushd "$TARGET_DIR"
# pgpassword needs to be exported - otherwise drush will prompt for the password (4 times!)
# with PGPASSWORD libpq will read the password itself
#
# the accout login is used for geoserver - so it should match
# a geoserver account

#    install_configure_form.cartaro_demo=1
SITE_INSTALL_OPTS="cartaro
    install_configure_form.cartaro_demo=1
    install_configure_form.geoserver_workspace=cartaro
    install_configure_form.geoserver_namespace=cartaro
    install_configure_form.geoserver_url=$GEOSERVER_URL
    --account-pass=$GEO_PASS
    --account-name=$GEO_ADMIN
    --site-name=Cartaro Demo
    --db-url=pgsql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME
    --clean-url=1
    --yes"

PGPASSWORD=$DB_PASSWORD $DRUSH_DIR/drush site-install $SITE_INSTALL_OPTS

# silence errors 
$DRUSH_DIR/drush variable-set error_level 0

popd

#######################
# Symlink for Apache2
#######################

echo "[install_cartaro.sh] Create Apache2 Symlinks ..."


if [ ! -L /var/www/cartaro ]; then
	ln -s $TARGET_DIR /var/www/cartaro
fi  

###########################
# Create scripts start and shutdown
###########################

echo "[install_cartaro.sh] Create start and shutdown scripts ..."

if [ ! -d "$TARGET_DIR/bin" ]; then
    mkdir -p "$TARGET_DIR/bin"
fi

if [ ! -f "$TARGET_DIR/bin/start_cartaro.sh" ]; then

cat << EOF > "$TARGET_DIR/bin/start_cartaro.sh"
#!/bin/sh

# TODO nicer way to find whether geoserver is already running or not
$GS_PATH/bin/stutdown.sh &
sleep 20;
$GS_PATH/bin/startup.sh &
/etc/init.d/postgresql start
/etc/init.d/apache2 start

DELAY=40

(
for TIME in \`seq \$DELAY\` ; do
      sleep 1
        echo "\$TIME \$DELAY" | awk '{print int(0.5+100*\$1/\$2)}'
        done
        ) | zenity --progress --auto-close --text "Cartaro is starting...."

zenity --info --text "Starting web browser ... have fun with Cartaro!"
firefox "http://localhost/cartaro"
EOF

fi

if [ ! -f "$TARGET_DIR/bin/stop_cartaro.sh" ]; then

cat << EOF  > "$TARGET_DIR/bin/stop_cartaro.sh"
#!/bin/sh

$GS_PATH/bin/stutdown.sh &
zenity --info --text "Cartaro is stopped"
EOF

fi

chown -R $USER_NAME "${TARGET_DIR}/bin"
chmod -R u+x "${TARGET_DIR}/bin"

##################################
# Copy Icons and create Desktop Icon
#################################

echo "[install_cartaro.sh] Create desktop icons ..."

if [ ! -f /usr/local/share/icons/logo-cartaro-48.png ]; then
    pushd "/usr/local/share/icons"
    wget http://cartaro.org/sites/cartaro.org/themes/cartaro_org/img/logos/logo-cartaro-48.png 
    popd
fi


## start icon
if [ ! -f "/usr/share/applications/cartaro-start.desktop" ]; then

cat << EOF > /usr/share/applications/cartaro-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Cartaro
Comment=Cartaro $CARTARO_VERSION
Categories=Application;
Exec=$TARGET_DIR/bin/start_cartaro.sh
Icon=/usr/local/share/icons/logo-cartaro-48.png
Terminal=false
EOF

cp -a /usr/share/applications/cartaro-start.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/cartaro-start.desktop"

fi


## stop icon
if [ ! -f "/usr/share/applications/cartaro-stop.desktop" ]; then

cat << EOF > /usr/share/applications/cartaro-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Cartaro
Comment=Cartaro $CARTARO_VERSION
Categories=Application;
Exec=$TARGET_DIR/bin/stop_cartaro.sh
Icon=/usr/local/share/icons/logo-cartaro-48.png
Terminal=false
EOF

cp -a /usr/share/applications/cartaro-stop.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/cartaro-stop.desktop"

fi

## documentation icon

if [ ! -f "/usr/share/applications/cartaro-docs.desktop" ]; then

cat << EOF > /usr/share/applications/cartaro-docs.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Cartaro documentation
Comment=Cartaro $CARTARO_VERSION Documentation
Categories=Application;
Exec=firefox "$DOC_DIR/user/index.html"
Icon=/usr/local/share/icons/logo-cartaro-48.png
Terminal=false
EOF

cp -a /usr/share/applications/cartaro-docs.desktop "$USER_HOME/Desktop/"
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/Desktop/cartaro-docs.desktop"

fi

####################################
# Fetch HTML Documentation and create symlink
###################################

echo "[install_cartaro.sh] Download Documentation ..."


# TODO

echo "==============================================================="
echo "finished install_cartaro.sh"
echo "==============================================================="


