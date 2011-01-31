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

#set the postgresql database username and password. Note that if this is changed, /var/lib/tomcat6/webapps/petascope/setting.properties must be modified to reflect the changes
WCPS_DATABASE="wcpsdb"
WCPS_USER="wcpsuser"
WCPS_PASSWORD="UD0b9uTt"


#get and install required packages
PACKAGES="git-core make autoconf automake libtool gawk flex bison ant g++ gcc cpp libstdc++6 openjdk-6-jdk tomcat6 libreadline-dev libssl-dev libncurses5-dev postgresql libecpg-dev libtiff4-dev libjpeg62-dev libhdf4g-dev libpng12-dev libnetpbm10-dev doxygen tomcat6 php5-cgi wget"
apt-get update && apt-key update &&  apt-get install --yes $PACKAGES
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi


#download and install rasdaman
git clone git://kahlua.eecs.jacobs-university.de/rasdaman.git 
# git not working now becuase trac is down
cd rasdaman
mkdir /var/log/rasdaman
chmod 777 /var/log/rasdaman
./configure --prefix=/usr/local --with-logdir=/var/log/rasdaman  && make clean && 
make
make install
if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi


su - $USER_NAME -c "dropdb RASBASE"
chmod 777 /usr/local/bin/*
chmod 777 /var/log/rasdaman
sed -i "s/RASDAMAN_USER=rasdaman/RASDAMAN_USER=$USER_NAME/g" /usr/local/bin/create_db.sh

su - $USER_NAME create_db.sh
su - $USER_NAME stop_rasdaman.sh
su - $USER_NAME start_rasdaman.sh

cd ../

wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/app-data/rasdaman/rasdaman_data.tar.gz
tar xzf rasdaman_data.tar.gz -C .

#import demo data into rasdaman
cd rasdaman_data/DataImport
make drop
make all

#copy demo applications into tomcat webapps directory
cd ../
rm -r  /var/lib/tomcat6/webapps/earthlook
rm -r  /var/lib/tomcat6/webapps/gwtWebView
rm -r  /var/lib/tomcat6/webapps/petascope
rm -r  /var/lib/tomcat6/webapps/JavaBridgeTemplate5541.war
mv rasdaman/* /var/lib/tomcat6/webapps/
chmod -R 777 /var/lib/tomcat6/webapps/earthlook

#create and insert data into rasdaman/petascope metadata database
su - $USER_NAME -c "dropuser $WCPS_USER"
su - $USER_NAME -c "createuser $WCPS_USER --superuser"
su - $USER_NAME -c "psql -c \"ALTER ROLE $WCPS_USER  with PASSWORD '$WCPS_PASSWORD';\""
su - $USER_NAME -c "dropdb wcpsdb"
su - $USER_NAME -c "createdb -T template0 $WCPS_DATABASE"
su - $USER_NAME -c "pg_restore -d $WCPS_DATABASE $(pwd)/wcpsdb -O"
if [ $? -ne 0 ] ; then
   echo "ERROR: can not insert data into metadata database."
   exit 1
fi

su - $USER_NAME stop_rasdaman.sh
su - $USER_NAME start_rasdaman.sh

#clean up
cd ../
rm rasdaman* -rf


#add rasdaman/earthlook to the ubuntu menu icons
if [ ! -e /usr/share/applications/Start_Rasdaman_Server.desktop ] ; then
   cat << EOF > /usr/share/applications/Start_Rasdaman_Server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name="Start Rasdaman Server"
Comment="Start Rasdaman Server"
Categories=Application;Education;Geography;
Exec=start_rasdaman.sh
Icon=gnome-globe
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi

if [ ! -e /usr/share/applications/Stop_Rasdaman_Server.desktop ] ; then
   cat << EOF > /usr/share/applications/Stop_Rasdaman_Server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop RasdamanServer
Comment=Stop Rasdaman Server
Categories=Application;Education;Geography;
Exec=stop_rasdaman.sh
Icon=gnome-globe
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi


if [ ! -e /usr/share/applications/Earthlook.desktop ] ; then
   cat << EOF > /usr/share/applications/Earthlook.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Rasdaman-Earthlook Demo
Comment=Rasdaman Demo And Tutorial
Categories=Application;Education;Geography;
Categories=Geospatial;Web Services;Earthlook Demo;
Exec=firefox  http://localhost:8080/earthlook
Icon=gnome-globe
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF
fi



