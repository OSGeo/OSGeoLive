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

# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

#set the postgresql database username and password. Note that if this is changed, /var/lib/tomcat6/webapps/petascope/setting.properties must be modified to reflect the changes
WCPS_DATABASE="wcpsdb"
WCPS_USER="wcpsuser"
WCPS_PASSWORD="UD0b9uTt"


TMP="/tmp/build_rasdaman"
mkdir "$TMP"
cd "$TMP"

#get and install required packages
PACKAGES="git-core make autoconf automake libtool gawk flex bison ant g++ gcc cpp libstdc++6 libreadline-dev libssl-dev openjdk-6-jdk libncurses5-dev postgresql libecpg-dev libtiff4-dev libjpeg62-dev libhdf4g-dev libpng12-dev libnetpbm10-dev doxygen tomcat6 php5-cgi wget"
apt-get update && apt-key update &&  apt-get install --assume-yes $PACKAGES
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi


#download and install rasdaman
git clone git://kahlua.eecs.jacobs-university.de/rasdaman.git 
cd rasdaman
mkdir /var/log/rasdaman
chown ${USER_NAME} /var/log/rasdaman -R
chmod  777  /var/log/rasdaman -R
./configure --prefix=/usr/local --with-logdir=/var/log/rasdaman  && make
make install
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi
${j}bar”
chown ${USER_NAME} /usr/local/bin/* -R
chmod 774 /usr/local/bin/*
sed -i "s/RASDAMAN_USER=rasdaman/RASDAMAN_USER=$USER_NAME/g" /usr/local/bin/create_db.sh

#test if rasbase exists, if not create rasbase database
test_RASBASE=$(su - $USER_NAME -c "psql --quiet  --list | grep \"RASBASE \" ")
if [ "$test_RASBASE" == "" ]; then
	su - $USER_NAME create_db.sh
fi


su - $USER_NAME start_rasdaman.sh

cd ../

wget -c --progress=dot:mega http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo/rasdaman_data.tar.gz

tar xzf rasdaman_data.tar.gz -C .

#import demo data into rasdaman
echo importing data...
cd rasdaman_data/DataImport
make all

#copy demo applications into tomcat webapps directory
cd ../

if [ ! -d "/var/lib/tomcat6/webapps/earthlook" ]; then
	echo moving earthlook folder into tomcat webapps...
	mv rasdaman/* /var/lib/tomcat6/webapps/
fi


#create and insert data into rasdaman/petascope metadata database
echo creating users and metadata database
su - $USER_NAME -c "createuser $WCPS_USER --superuser"
su - $USER_NAME -c "psql template1 --quiet -c \"ALTER ROLE $WCPS_USER  with PASSWORD '$WCPS_PASSWORD';\""
echo 2
test_WCPSDB=$(su - $USER_NAME -c "psql --quiet  --list | grep \"$WCPS_DATABASE \" ")
echo 3
if [ "$test_WCPSDB" == "" ]; then
	su - $USER_NAME -c "createdb  -T template0 $WCPS_DATABASE"
echo 4	
su - $USER_NAME -c "pg_restore  -d $WCPS_DATABASE $(pwd)/wcpsdb -O"
	if [ $? -ne 0 ] ; then
		echo "ERROR: can not insert data into metadata database."
		exit 1
	fi
fi

echo cleaning up...
su - $USER_NAME stop_rasdaman.sh
su - $USER_NAME start_rasdaman.sh

#clean up
apt-get autoremove --assume-yes openjdk-6-jdk libreadline-dev libssl-dev libncurses5-dev libtiff4-dev libjpeg62-dev libhdf4g-dev libpng12-dev libnetpbm10-dev
apt-get install openjdk-6-jre libecpg6 --assume-yes
cd ../
rm rasdaman* -rf
rm "$TMP" -rf
#add rasdaman/earthlook to the ubuntu menu icons
if [ ! -e /usr/share/applications/start_rasdaman_server.desktop ] ; then
   cat << EOF > /usr/share/applications/start_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=start rasdaman server
Comment=start rasdaman server
Categories=Geospatial;Servers;
Exec=start_rasdaman.sh
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF
fi

if [ ! -e /usr/share/applications/stop_rasdaman_server.desktop ] ; then
   cat << EOF > /usr/share/applications/stop_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=stop rasdaman server
Comment=stop rasdaman server
Categories=Geospatial;Servers;
Exec=stop_rasdaman.sh
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF
fi


if [ ! -e /usr/share/applications/rasdaman-earthlook-demo.desktop ] ; then
   cat << EOF > /usr/share/applications/rasdaman-earthlook-demo.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=rasdaman-earthlook demo
Comment=rasdaman demo and tutorial
Categories=Geospatial;Servers;
Exec=firefox  http://localhost:8080/earthlook
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF
fi

cp /usr/share/applications/stop_rasdaman_server.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/start_rasdaman_server.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/rasdaman-earthlook-demo.desktop "$USER_HOME/Desktop/"

