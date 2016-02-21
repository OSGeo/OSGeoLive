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
# Copyright 2003-2009 Peter Baumann / rasdaman GmbH.
#
# For more information please see <http://www.rasdaman.org>
# or contact Peter Baumann via <baumann@rasdaman.com>.
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


# 1 = install everything
# 0 = setup just petascope (this should be used only for testing)
FULL=1

OSGEOLIVE_TAG="v9.0.4"

VERSION=9.0.4
RASDAMAN_LOCATION="http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi

if [ -z "$GROUP_NAME" ] ; then
   GROUP_NAME="user"
fi

TOMCAT_USER_NAME="tomcat7"
USER_HOME="/home/$USER_NAME"
RASDAMAN_HOME="/usr/local/rasdaman"
TMP="/tmp/build_rasdaman"
WARDIR="/var/lib/tomcat7/webapps"
TOMCAT_CONFDIR="/var/lib/tomcat7/conf"
SETTINGS="$RASDAMAN_HOME/etc/petascope.properties"
EARTHLOOKDIR="/var/www/html"
BIN="/usr/local/bin"

# set the postgresql database username and password.
WCPS_DATABASE="petascopedb"
WCPS_USER="petauser"
WCPS_PASSWORD="petapasswd"

service tomcat7 start

rm -rf "$TMP"
rm -rf "$RASDAMAN_HOME"
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
 libhdf4-0 libpng12-dev libnetpbm10-dev tomcat7 php5-cgi libedit-dev\
 wget libgdal-dev openjdk-7-jdk libnetcdf-dev rpcbind git rpcbind libsigsegv-dev"


pkg_cleanup()
{
   # be careful that no other project on the disc wanted any of these!

  apt-get --yes remove libtool bison comerr-dev doxygen doxygen-latex \
     flex krb5-multidev libecpg-dev libjpeg-dev libedit-dev\
     libkrb5-dev libncurses5-dev libnetpbm10-dev libpng12-dev \
     libpq-dev libreadline-dev libreadline6-dev libtiff4-dev \
     luatex libgssrpc4 libkdb5-7 libgdal-dev libsigsegv-dev

  apt-get --yes autoremove
}


if [ "$FULL" -eq 1 ] ; then

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
  git checkout "$OSGEOLIVE_TAG"

  mkdir -p "$RASDAMAN_HOME/log"
  chgrp users "$RASDAMAN_HOME/log/" -R
  chmod g+w "$RASDAMAN_HOME/log/" -R
  adduser "$USER_NAME" users
  autoreconf -fi

  # 08feb16 quiet the configure/make output
  ./configure --with-logdir="$RASDAMAN_HOME"/log \
      --prefix="$RASDAMAN_HOME" --with-wardir="$WARDIR" \
      --with-netcdf  > /tmp/rasdaman_config_out.txt

  if [ $? -ne 0 ] ; then
     echo "ERROR: configure failed."
     cat /tmp/rasdaman_config_out.txt
     pkg_cleanup
     exit 1
  fi

  make version > /tmp/rasdaman_make_out.txt 2> /tmp/rasdaman_make_outerr.txt
  make > /tmp/rasdaman_make_out0.txt 2> /tmp/rasdaman_make_outerr0.txt
  if [ $? -ne 0 ] ; then
     echo "ERROR: compilation failed."
     cat /tmp/rasdaman_make*
     pkg_cleanup
     exit 1
  fi

  make install  > /tmp/rasdaman_make_out.txt 2> /tmp/rasdaman_make_outerr.txt
  if [ $? -ne 0 ] ; then
     echo "ERROR: package install failed."
     cat /tmp/rasdaman_make*
     pkg_cleanup
     exit 1
  fi

  # free up the disk space
  make clean > /tmp/rasdaman_make_out.txt 2> /tmp/rasdaman_make_outerr.txt


  # setup rasdaview
  mv "$RASDAMAN_HOME"/bin/rview "$RASDAMAN_HOME"/bin/rview.bin
  cp "$RASDAMAN_HOME"/share/rasdaman/errtxts* "$RASDAMAN_HOME"/bin/
  RASVIEWSCRIPT="$RASDAMAN_HOME"/bin/rasdaview
  echo "#!/bin/bash" > "$RASVIEWSCRIPT"
  echo "export RASVIEWHOME=$RASDAMAN_HOME/bin" >> "$RASVIEWSCRIPT"
  echo "cd $RASVIEWHOME && ./rview.bin" >> "$RASVIEWSCRIPT"
  chmod +x "$RASVIEWSCRIPT"

  if [ -f /etc/init/portmap.conf ]; then
     # allow starting portmap in "insecure mode", required by rasdaview
     sed -i 's/OPTIONS="-w"/OPTIONS="-w -i"/g' /etc/init/portmap.conf

     # restart portmap
     stop portmap
     killall rpcbind
     initctl reload-configuration portmap
     start portmap
  fi

  # this needs to be fixed upstream in rasdaman
  cp "$TMP"/rasdaman/config.h "$RASDAMAN_HOME"/include

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

fi # if FULL

export PATH="$PATH:$RASDAMAN_HOME/bin"

# Add sleep to start_rasdaman.sh to avoid race condition
sed -i '84i\sleep 0.5' /usr/local/rasdaman/bin/start_rasdaman.sh

# Make a request to secore to start the load process
sed -i "55i\nohup wget --spider 'localhost:8080/petascope_earthlook?query=for t1 in (NN3_1) return encode(t1, \"csv\")' &" /usr/local/rasdaman/bin/start_rasdaman.sh

#
#-------------------------------------------------------------------------------
# setup petascope
#

# create petascope database/user
echo "Creating users and metadata database..."
su - $USER_NAME -c "createuser $WCPS_USER --superuser"
su - $USER_NAME -c "psql template1 --quiet -c \"ALTER ROLE $WCPS_USER  with PASSWORD '$WCPS_PASSWORD';\""
su - $USER_NAME -c "createuser $USER --superuser"


# set to tomcat user, as tomcat will run the servlet
sed -i "s/^metadata_user=.\+/metadata_user=$WCPS_USER/" "$SETTINGS"
sed -i "s/^metadata_pass=.\+/metadata_pass=$WCPS_PASSWORD/" "$SETTINGS"

echo "Updated database."


#
#-------------------------------------------------------------------------------
# download, extract, and import demo data into rasdaman
#

cd "$TMP"

if [ ! -d "rasdaman_data_v9" ] ; then
  # 40mb download
  wget -c --progress=dot:mega "$RASDAMAN_LOCATION/rasdaman_data_v9.tar.gz"
  tar xzmf rasdaman_data_v9.tar.gz -C . --no-same-owner
fi

echo -n "Importing data... "
cd rasdaman_data_v9/

sudo service tomcat7 stop

for db in RASBASE petascopedb; do
    dropdb $db > /dev/null 2>&1
    createdb "$db"
    echo "FIXME: --quiet?"
    psql -d "$db" -q -f "$db.sql" > /dev/null 2>&1
    psql -d "$db" -c 'VACUUM ANALYZE'
done

echo "ok."

#
#-------------------------------------------------------------------------------
# download earthlook web site
#

cd "$TMP"

if [ ! -d "public_html" ] ; then
  # 105mb download
  wget -c --progress=dot:mega "$RASDAMAN_LOCATION/earthlook.tar.gz"
  tar xzmf earthlook.tar.gz -C . --no-same-owner
fi

echo "copying earthlook folder into $EARTHLOOKDIR/rasdaman-demo..."
#cp -r public_html "$EARTHLOOKDIR/rasdaman-demo"
rm -r "$EARTHLOOKDIR/rasdaman-demo"
mv public_html "$EARTHLOOKDIR/rasdaman-demo"

adduser "$USER_NAME" www-data
#chmod g+w /var/www/html/rasdaman-demo/demos/demo_items/img/climate*/
#chmod g+w /var/www/html/rasdaman-demo/demos/demo_items/img/ccip_processing_files/
#chgrp www-data /var/www/html/rasdaman-demo/demos/demo_items/img/climate*/
#chgrp www-data /var/www/html/rasdaman-demo/demos/demo_items/img/ccip_processing_files/


mv /var/lib/tomcat7/webapps/rasdaman.war \
   /var/lib/tomcat7/webapps/petascope_earthlook.war
rm -rf /var/lib/tomcat7/webapps/rasdaman.war
rm -rf /var/lib/tomcat7/webapps/petascope

#
#-------------------------------------------------------------------------------
# Enable webgl in firefox
#
sudo echo 'pref("webgl.force-enabled", true);' > /usr/lib/firefox/defaults/pref/all-rasdaman.js

#
#-------------------------------------------------------------------------------
# create scripts to launch with tomcat
#
RASDAMAN_BIN_FOLDER="/usr/local/rasdaman/bin"
mkdir -p "$RASDAMAN_BIN_FOLDER"
chgrp users "$RASDAMAN_BIN_FOLDER"

if [ ! -e "$RASDAMAN_BIN_FOLDER"/rasdaman-start.sh ] ; then
   cat << EOF > "$RASDAMAN_BIN_FOLDER"/rasdaman-start.sh
#!/bin/sh
STAT=\`sudo service tomcat7 status | grep pid\`
if [ -z "\$STAT" ] ; then
    sudo service tomcat7 start
fi
/usr/local/bin/start_rasdaman.sh
zenity --info --text "Rasdaman started"
EOF
fi

if [ ! -e "$RASDAMAN_BIN_FOLDER"/rasdaman-stop.sh ] ; then
   cat << EOF > "$RASDAMAN_BIN_FOLDER"/rasdaman-stop.sh
#!/bin/sh
STAT=\`sudo service tomcat7 status | grep pid\`
if [ -n "\$STAT" ] ; then
    sudo service tomcat7 stop
fi
/usr/local/bin/stop_rasdaman.sh
zenity --info --text "Rasdaman stopped"
EOF
fi

chmod 755 "$RASDAMAN_BIN_FOLDER"/rasdaman-start.sh
chmod 755 "$RASDAMAN_BIN_FOLDER"/rasdaman-stop.sh

#
#-------------------------------------------------------------------------------
# install desktop stuff
#

# add rasdaman/earthlook to the ubuntu menu icons
mkdir -p /usr/local/share/applications
cat << EOF > /usr/local/share/applications/start_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Rasdaman Server
Comment=Start Rasdaman Server
Categories=Application;Education;Geography;
Exec=$RASDAMAN_BIN_FOLDER/rasdaman-start.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF


cat << EOF > /usr/local/share/applications/stop_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Rasdaman Server
Comment=Stop Rasdaman Server
Categories=Application;Education;Geography;
Exec=$RASDAMAN_BIN_FOLDER/rasdaman-stop.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF


cat << EOF > /usr/local/share/applications/rasdaman-earthlook-demo.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Rasdaman-Earthlook Demo
Comment=Rasdaman Demo and Tutorial
Categories=Application;Education;Geography;
Exec=firefox  http://localhost/rasdaman-demo/
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp /usr/local/share/applications/stop_rasdaman_server.desktop \
   "$USER_HOME/Desktop/"
cp /usr/local/share/applications/start_rasdaman_server.desktop \
   "$USER_HOME/Desktop/"
cp /usr/local/share/applications/rasdaman-earthlook-demo.desktop \
   "$USER_HOME/Desktop/"

chown "$USER_NAME.$GROUP_NAME" $USER_HOME/Desktop/*rasdaman*.desktop


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
/etc/init.d/tomcat7 stop
su - "$USER_NAME" "$RASDAMAN_HOME"/bin/stop_rasdaman.sh
rm -f "$RASDAMAN_HOME"/log/*.log
chown root "$RASDAMAN_HOME"/etc/rasmgr.conf


## Copy startup script for rasdaman
ln -s "$RASDAMAN_HOME"/bin/start_rasdaman.sh "$BIN"/start_rasdaman.sh
ln -s "$RASDAMAN_HOME"/bin/stop_rasdaman.sh "$BIN"/stop_rasdaman.sh


### rasmgr.conf wants the hostname to be defined at build time, but the hostname on our
###   ISO and VM are different ('user' vs 'osgeo-live'). so we have to re-set the value
###   at boot time.
if [ `grep -c 'rasdaman' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local
    echo 'sed -i -e "s/ -host [^ ]*/ -host `hostname`/" /usr/local/rasdaman/etc/rasmgr.conf' >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi

# remove secore
#rm -rf $WARDIR/def

# start stopped services
start_rasdaman.sh
pgrep rasserver > /dev/null
if [ $? -ne 0 ] ; then
  stop_rasdaman.sh
  start_rasdaman.sh
fi

# Activate tomcat autodeploy option
sed -i 's/unpackWARs=\"false\"/unpackWARs=\"true\"/g' $TOMCAT_CONFDIR/server.xml
sed -i 's/autoDeploy=\"false\"/autoDeploy=\"true\"/g' $TOMCAT_CONFDIR/server.xml

# We need to have enough tomcat memory for secor3e to extract the CRS definitions
sed -i 's|JAVA_OPTS="-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC"|JAVA_OPTS="-Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Xms512m -Xmx1024m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:PermSize=256m -XX:+DisableExplicitGC"|g' /etc/default/tomcat7

service tomcat7 start
sleep 60
service tomcat7 stop
stop_rasdaman.sh

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
