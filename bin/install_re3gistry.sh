#!/bin/sh
#############################################################################
#
# Purpose: This script will install INSPIRE Re3gistry
# Author:
# Version 2020-08-28
#
#############################################################################
# Copyright (c) 2011-2019 The Open Source Geospatial Foundation and others.
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
#############################################################################

# =============================================================================
# Install script for Re3gistry
# =============================================================================
#
# Variables
# -----------------------------------------------------------------------------
START=$(date +%M:%S)
./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

TMP="/tmp/build_re3gistry"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
TOMCAT_USER_NAME="tomcat"
TOMCAT_SCRIPT_NAME="tomcat9"
REGISTRY_WEB_APP_NAME="re3gistry2"
REGISTRY_ICON_NAME="inspire.png" #to be changed to the INSPIRE logo
REGISTRY_URL="http://localhost:8080/$REGISTRY_WEB_APP_NAME"
REGISTRY_QUICKSTART_URL="http://localhost/osgeolive/en/quickstart/re3gistry_quickstart.html"
REGISTRY_OVERVIEW_URL="http://localhost/osgeolive/en/overview/re3gistry_overview.html"
REGISTRY_WAR_INSTALL_FOLDER="/var/lib/$TOMCAT_SCRIPT_NAME/webapps"
REGISTRY_INSTALL_FOLDER="/usr/local/registry2"
REGISTRY_BIN_FOLDER="/usr/local/share/registry2"
REGISTRY_VERSION="2.0"
PG_OPTIONS="--client-min-messages=warning"
PG_USER="user"
PG_PASSWORD="user"
PG_SCRIPT_NAME="postgresql"
PG_DB_NAME="re3gistry_db"
JAVA_PKG="default-jre"
SOLR_SCRIPT_NAME="solr-tomcat" #added to comply with the requirements of the Re3gistry
GIT_SCRIPT_NAME="git" #added to ensure git is installed for cloning the Re3gistry repository
# -----------------------------------------------------------------------------
#
echo "[$START]: $REGISTRY_WEB_APP_NAME $REGISTRY_VERSION install started"
echo "TMP: $TMP"
echo "USER_NAME: $USER_NAME"
echo "USER_HOME: $USER_HOME"
echo "TOMCAT_USER_NAME: $TOMCAT_USER_NAME"
echo "TOMCAT_SCRIPT_NAME: $TOMCAT_SCRIPT_NAME"
echo "REGISTRY_WAR_INSTALL_FOLDER: $REGISTRY_WAR_INSTALL_FOLDER"
echo "REGISTRY_INSTALL_FOLDER: $REGISTRY_INSTALL_FOLDER"
echo "REGISTRY_TAR_NAME: $REGISTRY_TAR_NAME"
echo "REGISTRY_TAR_URL: $REGISTRY_TAR_URL"
echo "REGISTRY_WEB_APP_NAME: $REGISTRY_WEB_APP_NAME"
echo "REGISTRY_ICON_NAME: $REGISTRY_ICON_NAME"
echo "REGISTRY_URL: $REGISTRY_URL"
echo "REGISTRY_QUICKSTART_URL: $REGISTRY_QUICKSTART_URL"
echo "REGISTRY_OVERVIEW_URL: $REGISTRY_OVERVIEW_URL"
echo "REGISTRY_VERSION: $REGISTRY_VERSION"
echo "PG_OPTIONS: $PG_OPTIONS"
echo "PG_USER: $PG_USER"
echo "PG_PASSWORD: $PG_PASSWORD"
echo "PG_SCRIPT_NAME: $PG_SCRIPT_NAME"
echo "PG_DB_NAME: $PG_DB_NAME"
echo "JAVA_PKG: $JAVA_PKG"
echo "SOLR_SCRIPT_NAME: $SOLR_SCRIPT_NAME"
echo "GIT_SCRIPT_NAME: $GIT_SCRIPT_NAME"
#
#
# =============================================================================
# Pre install checks
# =============================================================================

# 1 java
# 2 tomcat
# 3 postgresql
# 4 solr
# 5 git
#
#
#
# 1 Check for OpenJDK
#
if [ ! -x "`which java`" ] ; then
    apt-get -q update
    apt-get --assume-yes install $JAVA_PKG
fi
#
#
# 2 tomcat
#
if [ -f "/etc/init.d/$TOMCAT_SCRIPT_NAME" ] ; then
   	echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$TOMCAT_SCRIPT_NAME" "${TOMCAT_SCRIPT_NAME}-admin"
fi
#
#
# 3 postgresql
#
if [ -f "/etc/init.d/$PG_SCRIPT_NAME" ] ; then
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$PG_SCRIPT_NAME"
fi
#
#
#
# 4 Solr
# 
if [ -f "/etc/init.d/$SOLR_SCRIPT_NAME" ] ; then
    echo "[$(date +%M:%S)]: $SOLR_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $SOLR_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$SOLR_SCRIPT_NAME"
fi
#
#
# 5 git
#
if [ -f "/etc/init.d/$GIT_SCRIPT_NAME" ] ; then
    echo "[$(date +%M:%S)]: $GIT_SCRIPT_NAME service script found in /etc/init.d/."
else
    echo "[$(date +%M:%S)]: $GIT_SCRIPT_NAME not found. Installing it..."
    apt-get install --assume-yes "$GIT_SCRIPT_NAME"
fi

# =============================================================================
# The INSPIRE Re3Gistry installation process
# =============================================================================
# 1 Clone Git repository
# 2 Database set-up
# 2.1 insert structure and data
# 3 tomcat set-up
# 3.0 check for webapps folder in $REGISTRY_WAR_INSTALL_FOLDER
# 3.1 mv registry apps to webapps folder
# 3.2 change owner of the files in the webapps folder
#
#
# 1 Download Re3Gistry
#
# create the TMP directory and clone the Re3gistry git repository
mkdir -p "$TMP"
cd "$TMP"
git clone -b osgeolive15 https://github.com/ec-jrc/re3gistry.git
#
# copy logo
#mkdir -p /usr/local/share/icons
#if [ ! -e "/usr/local/share/icons/$REGISTRY_ICON_NAME" ] ; then
#    chmod 644 "$REGISTRY_ICON_NAME"
#    mv -v "$REGISTRY_ICON_NAME" /usr/local/share/icons/
#fi
#
#
# 2 Database set-up
#
# we need to stop tomcat around this process
TOMCAT=`systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l`
if [ $TOMCAT -eq 1 ]; then
    systemctl stop $TOMCAT_SCRIPT_NAME
    echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME stopped"
else
    echo "[$(date +%M:%S)]: $TOMCAT_SCRIPT_NAME already stopped"
fi
#
# we need a running postgresql server
POSTGRES=`systemctl status $PG_SCRIPT_NAME | grep "Active: active" | wc -l`
if [ $POSTGRES -ne 1 ]; then
    systemctl start $PG_SCRIPT_NAME
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME started"
else
    echo "[$(date +%M:%S)]: $PG_SCRIPT_NAME already started"
fi
#    Check for database installation
#
REGISTRY_DB_EXISTS="`su $PG_USER -c 'psql -l' | grep $PG_DB_NAME | wc -l`"
if [ $REGISTRY_DB_EXISTS -gt 0 ] ; then
    echo "[$(date +%M:%S)]: Re3gistry db $PG_DB_NAME exists -> drop it"
    su $PG_USER -c "dropdb $PG_DB_NAME"
fi
#
echo "[$(date +%M:%S)]: Create Re3gistry db"
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' createdb --owner=$PG_USER $PG_DB_NAME"

echo "[$(date +%M:%S)]: DB $PG_DB_NAME created"
#
#
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql -d $PG_DB_NAME -f $TMP/re3gistry/dist/db-scripts/registry2_drop-and-create-and-init.sql.orig"
echo "[$(date +%M:%S)]: $PG_DB_NAME -> Re3Gistry database filled"
#
# Create the password for the Postgres user.
#
sudo -u postgres psql -c "ALTER USER \"$PG_USER\" WITH PASSWORD '$PG_PASSWORD';"
#
# Final tidy up
#
su $PG_USER -c "PGOPTIONS='$PG_OPTIONS' psql -d $PG_DB_NAME -q -c 'VACUUM ANALYZE'"
#
# Create the initialisaton properties for the Re3gistry.
#
cat << EOF > "$TMP/re3gistry/dist/init.properties"
dbhost=localhost
dbport=5432
dbname=re3gistry_db
dbuser=user
dbpassword=user
statusbaseuri=http://localhost
solrurl=http://localhost:8080/solr/
smtphost=smtp.test-url.eu
applicationrooturl=http://localhost:8080/re3gistry2
EOF
#
# Execute the initialisation script.
#
chmod +x "$TMP/re3gistry/dist/init-config.sh"
cd $TMP/re3gistry/dist
"$TMP/re3gistry/dist/init-config.sh"
#
# Move the apps to the servlet container folder and change ownership to the tomcat user
#
cp -R "$TMP/re3gistry/dist/app/re3gistry2" "$REGISTRY_WAR_INSTALL_FOLDER"/ 
cp -R "$TMP/re3gistry/dist/app/re3gistry2restapi" "$REGISTRY_WAR_INSTALL_FOLDER"/
chown -v -R $TOMCAT_USER_NAME:$TOMCAT_USER_NAME "$REGISTRY_WAR_INSTALL_FOLDER"/* > /dev/null
#
echo "[$(date +%M:%S)]: $REGISTRY_WEB_APP_NAME $REGISTRY_VERSION installed in tomcat webapps folder"
#
#
#
# Startup/Stop scripts set-up
# =============================================================================
mkdir -p "$REGISTRY_BIN_FOLDER"
chgrp users "$REGISTRY_BIN_FOLDER"

if [ ! -e $REGISTRY_BIN_FOLDER/re3gistry-start.sh ] ; then
    cat << EOF > $REGISTRY_BIN_FOLDER/re3gistry-start.sh
#!/bin/bash
(sleep 5; echo "25"; sleep 5; echo "50"; sleep 5; echo "75"; sleep 5; echo "100") | zenity --progress --auto-close --text "INSPIRE Re3gistry starting"&
POSTGRES=\`sudo systemctl status $PG_SCRIPT_NAME | grep "Active: active" | wc -l\`
if [ \$POSTGRES -ne 1 ]; then
    sudo systemctl start $PG_SCRIPT_NAME
fi
TOMCAT=\`sudo systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l\`
if [ \$TOMCAT -ne 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME start
fi
firefox $REGISTRY_URL $REGISTRY_QUICKSTART_URL $REGISTRY_OVERVIEW_URL
EOF
fi
#
if [ ! -e $REGISTRY_BIN_FOLDER/re3gistry-stop.sh ] ; then
   cat << EOF > $REGISTRY_BIN_FOLDER/re3gistry-stop.sh
#!/bin/bash
TOMCAT=\`sudo systemctl status $TOMCAT_SCRIPT_NAME | grep "Active: active" | wc -l\`
if [ \$TOMCAT -eq 1 ]; then
    sudo service $TOMCAT_SCRIPT_NAME stop
fi
zenity --info --text "INSPIRE Re3gistry stopped"
EOF
fi
#
chmod 755 $REGISTRY_BIN_FOLDER/re3gistry-start.sh
chmod 755 $REGISTRY_BIN_FOLDER/re3gistry-stop.sh
#
#
# Desktop set-up
# =============================================================================
mkdir -p -v "$USER_HOME/Desktop"
#
# icon
# Relies on launchassist in home dir
mkdir -p /usr/local/share/applications
if [ ! -e /usr/local/share/applications/re3gistry-start.desktop ] ; then
    cat << EOF > /usr/local/share/applications/re3gistry-start.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start INSPIRE Re3gistry
Comment=INSPIRE Re3gistry
Categories=Geospatial;Servers;
Exec=$REGISTRY_BIN_FOLDER/re3gistry-start.sh
Icon=/usr/local/share/icons/$REGISTRY_ICON_NAME
Terminal=false
EOF
fi
#
#
cp -v /usr/local/share/applications/re3gistry-start.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/re3gistry-start.desktop"
#
if [ ! -e /usr/local/share/applications/re3gistry-stop.desktop ] ; then
    cat << EOF > /usr/local/share/applications/re3gistry-stop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop INSPIRE Re3gistry
Comment=INSPIRE Re3gistry
Categories=Geospatial;Servers;
Exec=$REGISTRY_BIN_FOLDER/re3gistry-stop.sh
Icon=/usr/local/share/icons/$REGISTRY_ICON_NAME
Terminal=false
EOF
fi
#
cp -v /usr/local/share/applications/re3gistry-stop.desktop "$USER_HOME/Desktop/"
chown -v $USER_NAME:$USER_NAME "$USER_HOME/Desktop/re3gistry-stop.desktop"
#
#
# Done. Thanks for staying till the end!
#
####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
echo -e "Timing:\nStart: $START\nEnd  : $(date +%M:%S)"
