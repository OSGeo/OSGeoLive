#!/bin/bash
#
#  Copyright (C) 2010 by Autodesk, Inc.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of version 2.1 of the GNU Lesser
#  General Public License as published by the Free Software Foundation.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

# About:
# ====
# This script will install MapGuide 

# Running:
# =======
# sudo ./install_mapguide.sh

USER_NAME="user"
USER_HOME="/home/$USER_NAME"
USER_DESKTOP="$USER_HOME/Desktop"

STARTDIR=`pwd`
TEMPDIR=/tmp/build_mapguide
URL="http://download.osgeo.org/mapguide/releases/2.2.0/Beta"
FDOVER=3.5.0-5460_i386
MGVER=2.2.0-4898_i386
MAESTROVER=2.0.0-4650_i386
MGDIR=/usr/local/mapguideopensource-2.2.0

# Create temporary download directory
mkdir -p ${TEMPDIR}
cd ${TEMPDIR}

# Install required packages 
apt-get -y install libexpat1 libssl0.9.8 odbcinst1debian1 unixodbc libcurl3 libxslt1.1
apt-get -y install mono-runtime libmono-winforms2.0-cil

# Resolve CentOS 5.4 / Ubuntu 10.04 shared lib differences with symlinks
if [ ! -e /usr/local/lib/libcrypto.so.6 ]; then
  ln -s /lib/libcrypto.so.0.9.8 /usr/local/lib/libcrypto.so.6
fi

if [ ! -e /usr/local/lib/libssl.so.6 ]; then
  ln -s /lib/libssl.so.0.9.8 /usr/local/lib/libssl.so.6
fi

if [ ! -e /usr/local/lib/libexpat.so.0 ]; then
  ln -s /lib/libexpat.so.1.5.2 /usr/local/lib/libexpat.so.0
fi

if [ ! -e /usr/local/lib/libldap-2.3.so.0 ]; then
  ln -s /usr/lib/libldap-2.4.so.2 /usr/local/lib/libldap-2.3.so.0
fi

if [ ! -e /usr/local/lib/liblber-2.3.so.0 ]; then
  ln -s /usr/lib/liblber-2.4.so.2 /usr/local/lib/liblber-2.3.so.0
fi

if [ ! -d /var/lock/mgserver ]; then
  mkdir /var/lock/mgserver
fi


# Download Ubuntu packages for FDO
for file in core gdal kingoracle ogr postgis sdf shp sqlite wfs wms
do
  wget --progress=dot:mega -N ${URL}/fdo-${file}_${FDOVER}.deb
done

# Download Ubuntu packages for MapGuide
for file in common server webextensions httpd
do
  wget -N --progress=dot:mega ${URL}/mapguideopensource-${file}_${MGVER}.deb
done

# Download Ubuntu package for Maestro
wget -N --progress=dot:mega ${URL}/mapguideopensource-maestro_${MAESTROVER}.deb

# Install Ubuntu packages for FDO
for file in core gdal kingoracle ogr postgis sdf shp sqlite wfs wms
do
  dpkg -E -G --install fdo-${file}_${FDOVER}.deb
done

# Install Ubuntu packages for MapGuide
for file in common server webextensions httpd
do
  dpkg -E -G --install mapguideopensource-${file}_${MGVER}.deb
done

# Install Ubuntu Package for Maestro
dpkg -E -G --install mapguideopensource-maestro_${MAESTROVER}.deb

# Download icons and scripts for MapGuide and Maestro
wget -nv -N ${URL}/livedvd/mapguideserver.png -P /usr/share/icons
wget -nv -N ${URL}/livedvd/mapguidemaestro.png -P /usr/share/icons
wget -nv -N ${URL}/livedvd/startmapguide.sh -P ${MGDIR}
chmod ugo+x ${MGDIR}/startmapguide.sh
wget -nv -N ${URL}/livedvd/stopmapguide.sh -P ${MGDIR}
chmod ugo+x ${MGDIR}/stopmapguide.sh

# Create shortcuts for MapGuide and Maestro
if [ ! -e $USER_DESKTOP/mapguideserverstart.desktop ] ; then
   cat << EOF > $USER_DESKTOP/mapguideserverstart.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start MapGuide
Comment=Start MapGuide Server
Categories=Application;Geography;
Exec=${MGDIR}/startmapguide.sh
Icon=/usr/share/icons/mapguideserver.png
Terminal=true
StartupNotify=true
Categories=Application
MimeType=
EOF
cp $USER_DESKTOP/mapguideserverstart.desktop /usr/share/applications
fi

if [ ! -e $USER_DESKTOP/mapguideserverstop.desktop ] ; then
   cat << EOF > $USER_DESKTOP/mapguideserverstop.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop MapGuide
Comment=Stop MapGuide Server
Categories=Application;Education;Geography;
Exec=${MGDIR}/stopmapguide.sh
Icon=/usr/share/icons/mapguideserver.png
Terminal=true
StartupNotify=true
Categories=Application
MimeType=
EOF
cp $USER_DESKTOP/mapguideserverstop.desktop /usr/share/applications
fi

if [ ! -e $USER_DESKTOP/mapguidemaestro.desktop ] ; then
   cat << EOF > $USER_DESKTOP/mapguidemaestro.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=MapGuide Maestro
Comment=Start MapGuide Maestro
Categories=Application;Geography;
Exec=/usr/bin/mono /usr/local/mapguidemaestro-2.0.0/Maestro.exe
Icon=/usr/share/icons/mapguidemaestro.png
Terminal=false
StartupNotify=false
Categories=Application
MimeType=
EOF
cp $USER_DESKTOP/mapguidemaestro.desktop /usr/share/applications
fi


# Replace the MapGuide Server startup script for Ubuntu compatibility
cat << EOF > ${MGDIR}/server/bin/mgserverd.sh
#!/bin/bash
export MENTOR_DICTIONARY_PATH=${MGDIR}/share/gis/coordsys
export LD_LIBRARY_PATH=/usr/local/fdo-3.5.0/lib:/usr/local/lib:"$LD_LIBRARY_PATH"
ulimit -s 1024

if [ ! -d /var/lock/mgserver ]; then
  mkdir /var/lock/mgserver
fi

pushd ${MGDIR}/server/bin
./mgserver daemon
popd
EOF

chmod ugo+x ${MGDIR}/server/bin/mgserverd.sh

# Replace the Apache envvars file to fix Ubuntu compatibility issues
cat << EOF > ${MGDIR}/webserverextensions/apache2/bin/envvars
export MENTOR_DICTIONARY_PATH=${MGDIR}/share/gis/coordsys
export LD_LIBRARY_PATH=/usr/local/fdo-3.5.0/lib:/usr/local/lib:${MGDIR}/lib:${MGDR}/webserverextensions/lib:${MGDIR}/webserverextensions/php/lib:"$LD_LIBRARY_PATH"
EOF

# Download and install Sheboygan sample data
if [ ! -d ${MGDIR}/webserverextensions/www/phpviewersample ]; then
wget --progress=dot:mega -N ${URL}/livedvd/sheboygansample.tgz
cd ${MGDIR}
tar -zxf ${TEMPDIR}/sheboygansample.tgz
fi

cd ${STARTDIR}

