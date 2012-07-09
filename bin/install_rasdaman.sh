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

# rasdaman src to be used
VERSION=8.3.0
RASDAMAN_LOCATION="http://www.rasdaman.com/Download"
RASDAMAN_TARBALL="rasdaman-$VERSION.tar.gz"

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
RASDAMAN_HOME="/usr/local/rasdaman"
TMP="/tmp/build_rasdaman"
WARDIR="/var/lib/tomcat6/webapps"

#set the postgresql database username and password.
# Note that if this is changed, /var/lib/tomcat6/webapps/petascope/setting.properties
# must be modified to reflect the changes
WCPS_DATABASE="petascopedb"
WCPS_USER="petauser"
WCPS_PASSWORD="UD0b9uTt"

mkdir -p "$TMP"
cd "$TMP"
if [ ! -d "$RASDAMAN_HOME" ]; then
        mkdir "$RASDAMAN_HOME"
fi

#get and install required packages
PACKAGES="make autoconf automake libtool gawk flex bison \
 g++ gcc cpp libstdc++6 libreadline-dev libssl-dev \
 libncurses5-dev postgresql libecpg-dev libtiff4-dev libjpeg-dev \
 libhdf4-0 libpng12-dev libnetpbm10-dev tomcat6 php5-cgi \
 wget libgdal1-dev openjdk-7-jdk libnetcdf-dev rpcbind"


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
     luatex libgssrpc4 libkadm5clnt-mit7 libkadm5srv-mit7 \
     libkdb5-4 libgdal1-dev libnetcdf-dev
  # remove jdk
  apt-get --yes remove ca-certificates-java libaccess-bridge-java \
     libaccess-bridge-java-jni libnss3-1d \
     tzdata-java

  apt-get --yes autoremove
}



#apt-get update

apt-key update

apt-get  -f install  --no-install-recommends --assume-yes $PACKAGES

if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi

# symlink from the installed libdfalt
ln -s /usr/lib/libdfalt.a /usr/lib/libdf.a
ln -s /usr/lib/libdfalt.la /usr/lib/libdf.la
ln -s /usr/lib/libdfalt.so /usr/lib/libdf.so
ln -s /usr/lib/libdfalt.so.0 /usr/lib/libdf.so.0
ln -s /usr/lib/libdfalt.so.0.0.0 /usr/lib/libdf.so.0.0.0
ln -s /usr/lib/libmfhdfalt.a /usr/lib/libmfhdf.a
ln -s /usr/lib/libmfhdfalt.la /usr/lib/libmfhdf.la
ln -s /usr/lib/libmfhdfalt.so /usr/lib/libmfhdf.so
ln -s /usr/lib/libmfhdfalt.so.0 /usr/lib/libmfhdf.so.0
ln -s /usr/lib/libmfhdfalt.so.0.0.0 /usr/lib/libmfhdf.so.0.0.0
ln -s /usr/lib/libgdal1.7.0.so.1 /usr/lib/libgdal1.7.0.so

#download and install rasdaman
#If folder already exists, delete it and download the latest version


if [  -d  rasdaman ] ; then
    rm -rf rasdaman
fi

git clone git://kahlua.eecs.jacobs-university.de/rasdaman.git
#wget -c --progress=dot:mega "$RASDAMAN_LOCATION/$RASDAMAN_TARBALL"
#tar xzf "$RASDAMAN_TARBALL"


cd "rasdaman"
mkdir -p "$RASDAMAN_HOME/log"
chown "$USER_NAME" "$RASDAMAN_HOME/log/" -R

./configure --with-logdir="$RASDAMAN_HOME"/log \
    --prefix="$RASDAMAN_HOME" --with-wardir="$WARDIR" --with-netcdf --with-hdf4 LIBS='-lecpg -lgdal1.7.0'

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
echo "#!/bin/bash" > $RASVIEWSCRIPT
echo "export RASVIEWHOME=$RASDAMAN_HOME/bin" >> $RASVIEWSCRIPT
echo "cd $RASVIEWHOME && ./rview.bin" >> $RASVIEWSCRIPT
chmod +x $RASVIEWSCRIPT

# setup permissions
chown "$USER_NAME" "$RASDAMAN_HOME"/bin/*
chmod 774 "$RASDAMAN_HOME"/bin/*
sed -i "s/RASDAMAN_USER=rasdaman/RASDAMAN_USER=$USER_NAME/g" \
   "$RASDAMAN_HOME"/bin/create_db.sh

# add rasdaman to the $PATH if not present
if [ `grep -c $RASDAMAN_HOME/rasdaman/bin $USER_HOME/.bashrc` -eq 0 ] ; then
   echo 'export PATH=$PATH:'$RASDAMAN_HOME/bin >> "$USER_HOME/.bashrc"
fi

#test if rasbase exists, if not create rasbase database
test_RASBASE=$(su - $USER_NAME -c "psql --quiet  --list | grep \"RASBASE \" ")
if [ -z "$test_RASBASE" ] ; then
   su - $USER_NAME $RASDAMAN_HOME/bin/create_db.sh
fi


# needed to start the RPC server
sed -i -e 's/OPTIONS="-w"/OPTIONS="-w -i"/' /etc/init.d/rpcbind
/etc/init.d/rpcbind restart
# needed to set the host name if it's empty
sed -i -e "s/ -host [^ ]*/ -host $HOSTNAME/" $RASDAMAN_HOME/etc/rasmgr.conf

su - "$USER_NAME" "$RASDAMAN_HOME"/bin/stop_rasdaman.sh
su - "$USER_NAME" "$RASDAMAN_HOME"/bin/start_rasdaman.sh

#-------------------------------------------------------------------------------
# setup petascope

# create petascope database/user
echo creating users and metadata database
su - $USER_NAME -c "createuser $WCPS_USER --superuser"
su - $USER_NAME -c "psql template1 --quiet -c \"ALTER ROLE $WCPS_USER  with PASSWORD '$WCPS_PASSWORD';\""
test_WCPSDB=$(su - $USER_NAME -c "psql --quiet  --list | grep \"$WCPS_DATABASE \" ")
if [ -z "$test_WCPSDB" ] ; then
    su - "$USER_NAME" -c "createdb  -T template0 $WCPS_DATABASE"
fi

cd applications/petascope
cp src/main/resources/settings.properties db
sed -i "s/^metadata_user=.\+/metadata_user=$WCPS_USER/" db/settings.properties
sed -i "s/^metadata_pass=.\+/metadata_pass=$WCPS_PASSWORD/" db/settings.properties
echo `pwd`
sed -i "s/\`hostname\`/\"127.0.0.1\"/" /tmp/build_rasdaman/rasdaman/applications/petascope/db/update_db.sh
echo "ccip_hack=true" >> db/settings.properties
cp db/settings.properties src/main/resources/settings.properties
#Download metadata for petascopedb
wget -c --progress=dot:mega \
   http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo/update0.sql
cp updata0.sql db/updata0.sql
#set up petascope db
su - $USER_NAME -c "cd $TMP/rasdaman/applications/petascope && make setupdb"
make install

cd -

cd ../

#-------------------------------------------------------------------------------
# download, extract, and import demo data into rasdaman
wget -c --progress=dot:mega \
   http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo/rasdaman_data_8-3.tar.gz

tar xzf rasdaman_data_8-3.tar.gz -C .

PATH="$PATH:$RASDAMAN_HOME/bin"
export PATH

echo importing data...
cd rasdaman_data_8-3/DataImport
sed -i "s/\/usr\/local\/bin\/insertdemo.sh localhost 7001 \/usr\/local\/share\/rasdaman\/examples\/images rasadmin rasadmin/\/usr\/local\/rasdaman\/bin\/insertdemo.sh localhost 7001 \/usr\/local\/rasdaman\/share\/rasdaman\/examples\/images rasadmin rasadmin /g"  demodata/Makefile
sed -i "s/PATH+=\":\$(RASGEO)\/bin\"/MAP=lena/g" lena/Makefile

make all


#copy demo applications into tomcat webapps directory
cd ../

if [ ! -d "/var/lib/tomcat6/webapps/earthlook" ] ; then
        echo moving earthlook folder into tomcat webapps...
        mv rasdaman/* /var/lib/tomcat6/webapps/
fi

#clean up
echo "cleaning up..."
/etc/init.d/rpcbind start
su - "$USER_NAME" "$RASDAMAN_HOME"/bin/stop_rasdaman.sh
su - "$USER_NAME" "$RASDAMAN_HOME"/bin/start_rasdaman.sh

pkg_cleanup

# Sun's Java should already be present..
apt-get install --assume-yes libecpg6

#Don't delete the tmp files, so we can stash them in a cache
#rm "$TMP" -rf


#add rasdaman/earthlook to the ubuntu menu icons
cat << EOF > /usr/share/applications/start_rasdaman_server.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Rasdaman Server
Comment=Start Rasdaman Server
Categories=Application;Education;Geography;
Exec=/usr/local/rasdaman/bin/start_rasdaman.sh
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
Exec=/usr/local/rasdaman/bin/stop_rasdaman.sh
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
Exec=firefox  http://localhost:8080/earthlook
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

cp /usr/share/applications/stop_rasdaman_server.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/start_rasdaman_server.desktop "$USER_HOME/Desktop/"
cp /usr/share/applications/rasdaman-earthlook-demo.desktop "$USER_HOME/Desktop/"


### rasmgr.conf wants the hostname to be defined at build time, but the hostname on our
###   ISO and VM are different ('user' vs 'osgeo-live'). so we have to re-set the value
###   at boot time.
if [ `grep -c 'rasdaman' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local
    echo 'sed -i -e "s/ -host [^ ]*/ -host $HOSTNAME/" /usr/local/rasdaman/etc/rasmgr.conf' >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi

