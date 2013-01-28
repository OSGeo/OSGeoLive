#!/bin/bash
#
# This file is part of rasdaman community.
#
# Rasdaman community is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rasdaman community is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with rasdaman community.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2003, 2004, 2005, 2006, 2007, 2008, 2009 Peter Baumann /
# rasdaman GmbH.
#
# For more information please see <http://www.rasdaman.org>
# or contact Peter Baumann via <baumann@rasdaman.com>.     
#

echo "==============================================================="
echo "install_rasdaman.sh"
echo "==============================================================="

# 1 = install everything
# 0 = setup just petascope (this should be used only for testing)
FULL=1

OSGEOLIVE_TAG="osgeolive-6.5"

VERSION=8.3.1
RASDAMAN_LOCATION="http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

if [ -z "$GROUP_NAME" ] ; then
   GROUP_NAME="user"
fi

TOMCAT_USER_NAME="tomcat6"
USER_HOME="/home/$USER_NAME"
RASDAMAN_HOME="/usr/local/rasdaman"
TMP="/tmp/build_rasdaman"
WARDIR="/var/lib/tomcat6/webapps"
SETTINGS="$RASDAMAN_HOME/etc/petascope.properties"
EARTHLOOKDIR="/var/www"
BIN="/usr/local/bin"

# set the postgresql database username and password.
WCPS_DATABASE="petascopedb"
WCPS_USER="petauser"
WCPS_PASSWORD="petapasswd"

mkdir -p "$TMP"
cd "$TMP"
chgrp users "$TMP" -R
chmod g+w "$TMP" -R

if [ ! -d "$RASDAMAN_HOME" ]; then
        mkdir "$RASDAMAN_HOME"
        chgrp users "$RASDAMAN_HOME" -R
        chmod g+w "$RASDAMAN_HOME" -R
fi

#get and install required packages
PACKAGES="make autoconf automake libtool gawk flex bison build-essential \
 g++ gcc cpp libstdc++6 libreadline-dev libssl-dev \
 libncurses5-dev postgresql libecpg-dev libtiff4-dev libjpeg-dev \
 libhdf4-0 libpng12-dev libnetpbm10-dev tomcat6 php5-cgi \
 wget libgdal1-dev openjdk-7-jdk libnetcdf-dev rpcbind git git-core rpcbind"


pkg_cleanup()
{
   # be careful that no other project on the disc wanted any of these!

  apt-get --yes remove preview-latex-style tex-common texlive-base \
     texlive-binaries texlive-common texlive-doc-base texlive-extra-utils \
     texlive-latex-base texlive-latex-extra texlive-latex-recommended \
     texlive-pictures libtool bison comerr-dev doxygen doxygen-latex \
     flex krb5-multidev latex-xcolor libecpg-dev libjpeg-dev \
     libkrb5-dev libncurses5-dev libnetpbm10-dev libpng12-dev \
     libpq-dev libreadline-dev libreadline6-dev libtiff4-dev \
     luatex libgssrpc4 libkadm5clnt-mit8 libkadm5srv-mit8 \
     libkdb5-6 libgdal1-dev libnetcdf-dev git git-core

  apt-get --yes autoremove
}


if [ $FULL -eq 1 ]; then

  apt-get -q update
  apt-key update
  apt-get install --no-install-recommends --assume-yes $PACKAGES

  if [ $? -ne 0 ] ; then
     echo "ERROR: package install failed."
     exit 1
  fi

  # download and install rasdaman
  if [ ! -d rasdaman ] ; then
    git clone git://kahlua.eecs.jacobs-university.de/rasdaman.git
  fi

  cd "rasdaman"
  
  # switch to current osgeo live tag
  git pull
  git checkout "$OSGEOLIVE_TAG"

  mkdir -p "$RASDAMAN_HOME/log"
  chgrp users "$RASDAMAN_HOME/log/" -R
  chmod g+w "$RASDAMAN_HOME/log/" -R
  adduser "$USER_NAME" users

  ./configure --with-logdir="$RASDAMAN_HOME"/log \
      --prefix="$RASDAMAN_HOME" --with-wardir="$WARDIR" \
      --with-netcdf

  if [ $? -ne 0 ] ; then
     echo "ERROR: configure failed."
     pkg_cleanup
     exit 1
  fi

  make
  if [ $? -ne 0 ] ; then
     echo "ERROR: compilation failed."
     pkg_cleanup
     exit 1
  fi

  make install
  if [ $? -ne 0 ] ; then
     echo "ERROR: package install failed."
     pkg_cleanup
     exit 1
  fi

  # setup rasdaview
  mv "$RASDAMAN_HOME"/bin/rview "$RASDAMAN_HOME"/bin/rview.bin
  cp "$RASDAMAN_HOME"/share/rasdaman/errtxts* "$RASDAMAN_HOME"/bin/
  RASVIEWSCRIPT="$RASDAMAN_HOME"/bin/rasdaview
  echo "#!/bin/bash" > "$RASVIEWSCRIPT"
  echo "export RASVIEWHOME=$RASDAMAN_HOME/bin" >> "$RASVIEWSCRIPT"
  echo "cd $RASVIEWHOME && ./rview.bin" >> "$RASVIEWSCRIPT"
  chmod +x "$RASVIEWSCRIPT"

  # allow starting portmap in "insecure mode", required by rasdaview
  sed -i 's/OPTIONS="-w"/OPTIONS="-w -i"/g' /etc/init/portmap.conf
  service portmap restart

  sed -i "s/RASDAMAN_USER=rasdaman/RASDAMAN_USER=$USER_NAME/g" \
     "$RASDAMAN_HOME"/bin/create_db.sh


  # add rasdaman to the $PATH if not present
  if [ `grep -c $RASDAMAN_HOME/rasdaman/bin $USER_HOME/.bashrc` -eq 0 ] ; then
     echo "export PATH=\"\$PATH:$RASDAMAN_HOME/bin\"" >> "$USER_HOME/.bashrc"
  fi
  if [ `grep -c rasdaman/bin /etc/skel/.bashrc` -eq 0 ] ; then
     echo "export PATH=\"\$PATH:$RASDAMAN_HOME/bin\"" >> "/etc/skel/.bashrc"
  fi
 
  # set host name
  chgrp -R users "$RASDAMAN_HOME"/etc/
  chmod -R g+w "$RASDAMAN_HOME"/etc/

  #why? can it be avoided? writes log files as 'user' to the filesystem
  su - "$USER_NAME" "$RASDAMAN_HOME"/bin/stop_rasdaman.sh
  su - "$USER_NAME" "$RASDAMAN_HOME"/bin/start_rasdaman.sh

fi # if FULL

export PATH="$PATH:$RASDAMAN_HOME/bin"

#
#-------------------------------------------------------------------------------
# setup petascope
#

# create petascope database/user
echo creating users and metadata database
su - $USER_NAME -c "createuser $WCPS_USER --superuser"
su - $USER_NAME -c "psql template1 --quiet -c \"ALTER ROLE $WCPS_USER  with PASSWORD '$WCPS_PASSWORD';\""
su - $USER_NAME -c "createuser $USER --superuser"


# set to tomcat user, as tomcat will run the servlet
sed -i "s/^metadata_user=.\+/metadata_user=$WCPS_USER/" $SETTINGS
sed -i "s/^metadata_pass=/metadata_pass=$WCPS_PASSWORD/" $SETTINGS

echo "Updated database"

#
#-------------------------------------------------------------------------------
# download, extract, and import demo data into rasdaman
#

cd $TMP

if [ ! -d "rasdaman_data" ]; then
  wget -c --progress=dot:mega "$RASDAMAN_LOCATION/rasdaman_data.tar.gz"
  tar xzmf rasdaman_data.tar.gz -C .
fi

# this needs to be fixed upstream in rasdaman
cp $TMP/rasdaman/config.h $RASDAMAN_HOME/include

echo "importing data..."
cd rasdaman_data/

for db in RASBASE petascopedb; do
  dropdb $db
  createdb $db
  psql -d $db -f $db.sql
done

#
#-------------------------------------------------------------------------------
# download earthlook web site
#

cd $TMP

if [ ! -d "public_html" ]; then
  wget -c --progress=dot:mega "$RASDAMAN_LOCATION/earthlook.tar.gz"
  tar xzmf earthlook.tar.gz -C .
fi

echo "copying earthlook folder into $EARTHLOOKDIR/rasdaman-demo..."
cp -r public_html "$EARTHLOOKDIR/rasdaman-demo"

mv /var/lib/tomcat6/webapps/petascope.war /var/lib/tomcat6/webapps/petascope_earthlook.war
rm -rf /var/lib/tomcat6/webapps/petascope.war
rm -rf /var/lib/tomcat6/webapps/petascope


#
#-------------------------------------------------------------------------------
# install desktop stuff
#

# add rasdaman/earthlook to the ubuntu menu icons
cat << EOF > /usr/share/applications/start_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Rasdaman Server
Comment=Start Rasdaman Server
Categories=Application;Education;Geography;
Exec=/usr/local/bin/start_rasdaman.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF


cat << EOF > /usr/share/applications/stop_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Rasdaman Server
Comment=Stop Rasdaman Server
Categories=Application;Education;Geography;
Exec=/usr/local/bin/stop_rasdaman.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF


cat << EOF > /usr/share/applications/rasdaman-earthlook-demo.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Rasdaman-Earthlook Demo
Comment=Rasdaman Demo and Tutorial
Categories=Application;Education;Geography;
Exec=firefox  http://localhost/rasdaman-demo/index-osgeolive.php
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/stop_rasdaman_server.desktop \
   "$USER_HOME/Desktop/"
cp /usr/share/applications/start_rasdaman_server.desktop \
   "$USER_HOME/Desktop/"
cp /usr/share/applications/rasdaman-earthlook-demo.desktop \
   "$USER_HOME/Desktop/"
chown "$USER_NAME.$GROUP_NAME" "$USER_HOME/Desktop/*rasdaman*.desktop"


#
#-------------------------------------------------------------------------------
# done, cleanup
#

if [ $FULL -eq 1 ]; then

  echo "cleaning up..."
  pkg_cleanup
  apt-get install --assume-yes libecpg6

fi # if FULL

# back to sleep & cleanup
/etc/init.d/tomcat6 stop
su - "$USER_NAME" "$RASDAMAN_HOME"/bin/stop_rasdaman.sh
rm -f "$RASDAMAN_HOME"/log/*.log
chown root "$RASDAMAN_HOME"/etc/rasmgr.conf


## Copy startup script for rasdaman
cp "$RASDAMAN_HOME"/bin/start_rasdaman.sh $BIN/start_rasdaman.sh
cp "$RASDAMAN_HOME"/bin/stop_rasdaman.sh $BIN/stop_rasdaman.sh
chmod 755 "$BIN"/st*_rasdaman.sh


### rasmgr.conf wants the hostname to be defined at build time, but the hostname on our
###   ISO and VM are different ('user' vs 'osgeo-live'). so we have to re-set the value
###   at boot time.
if [ `grep -c 'rasdaman' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local
    echo 'sed -i -e "s/ -host [^ ]*/ -host `hostname`/" /usr/local/rasdaman/etc/rasmgr.conf' >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi

cat <<EOF > /etc/postgresql/9.1/main/pg_hba.conf


stgreSQL Client Authentication Configuration File
# ===================================================
#
# Refer to the "Client Authentication" section in the PostgreSQL
# documentation for a complete description of this file.  A short
# synopsis follows.
#
# This file controls: which hosts are allowed to connect, how clients
# are authenticated, which PostgreSQL user names they can use, which
# databases they can access.  Records take one of these forms:
#
# local      DATABASE  USER  METHOD  [OPTIONS]
# host       DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostssl    DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
# hostnossl  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]
#
# (The uppercase items must be replaced by actual values.)
#
# The first field is the connection type: "local" is a Unix-domain
# socket, "host" is either a plain or SSL-encrypted TCP/IP socket,
# "hostssl" is an SSL-encrypted TCP/IP socket, and "hostnossl" is a
# plain TCP/IP socket.
#
# DATABASE can be "all", "sameuser", "samerole", "replication", a
# database name, or a comma-separated list thereof. The "all"
# keyword does not match "replication". Access to replication
# must be enabled in a separate record (see example below).
#
# USER can be "all", a user name, a group name prefixed with "+", or a
# comma-separated list thereof.  In both the DATABASE and USER fields
# you can also write a file name prefixed with "@" to include names
# from a separate file.
#
# ADDRESS specifies the set of hosts the record matches.  It can be a
# host name, or it is made up of an IP address and a CIDR mask that is
# an integer (between 0 and 32 (IPv4) or 128 (IPv6) inclusive) that
# specifies the number of significant bits in the mask.  A host name
# that starts with a dot (.) matches a suffix of the actual host name.
# Alternatively, you can write an IP address and netmask in separate
# columns to specify the set of hosts.  Instead of a CIDR-address, you
# can write "samehost" to match any of the server's own IP addresses,
# or "samenet" to match any address in any subnet that the server is
# directly connected to.
#
# METHOD can be "trust", "reject", "md5", "password", "gss", "sspi",
# "krb5", "ident", "peer", "pam", "ldap", "radius" or "cert".  Note that
# "password" sends passwords in clear text; "md5" is preferred since
# it sends encrypted passwords.
#
# OPTIONS are a set of options for the authentication in the format
# NAME=VALUE.  The available options depend on the different
# authentication methods -- refer to the "Client Authentication"
# section in the documentation for a list of which options are
# available for which authentication methods.
#
# Database and user names containing spaces, commas, quotes and other
# special characters must be quoted.  Quoting one of the keywords
# "all", "sameuser", "samerole" or "replication" makes the name lose
# its special character, and just match a database or username with
# that name.
#
# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can
# use "pg_ctl reload" to do that.

# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records.  In that case you will also need to make PostgreSQL
# listen on a non-local interface via the listen_addresses
# configuration parameter, or via the -i or -h command line switches.

#------------------------------------------------------------
# "local" is for Unix domain socket connections only
local   all         all                               trust
# IPv4 local connections:
host    all         all         127.0.0.1/32          trust
# IPv6 local connections:
host    all         all         ::1/128               trust
#------------------------------------------------------------


# DO NOT DISABLE!
# If you change this first entry you will need to make sure that the
# database superuser can access the database using some other method.
# Noninteractive access to all databases is required during automatic
# maintenance (custom daily cronjobs, replication, and similar tasks).
#
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            md5
#host    replication     postgres        ::1/128                 md5
EOF

start_rasdaman.sh
service tomcat6 start 
