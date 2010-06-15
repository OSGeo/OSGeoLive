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


TEMPDIR=/tmp/build_mapguide
URL="http://download.osgeo.org/mapguide/releases/2.2.0/Beta"
FDOVER=3.5.0-5460_i386
MGVER=2.2.0-4898_i386
MAESTROVER=2.0.0-4650_i386
# Create temporary download directory
mkdir -p ${TEMPDIR}
pushd ${TEMPDIR}

# Install required packages 
apt-get -y install libexpat1 libssl0.9.8 odbcinst1debian1 unixodbc libcurl3 libxslt1.1
apt-get -y install mono-runtime libmono-winforms2.0-cil

# Resolve CentOS 5.4 / Ubuntu 9.10 shared lib differences with symlinks
if [ ! -e /lib/libcrypto.so.6 ]; then
  ln -s /lib/libcrypto.so.0.9.8 /lib/libcrypto.so.6
fi

if [ ! -e /lib/libssl.so.6 ]; then
  ln -s /lib/libssl.so.0.9.8 /lib/libssl.so.6
fi

if [ ! -e /lib/libexpat.so.0 ]; then
  ln -s /lib/libexpat.so.1.5.2 /lib/libexpat.so.0
fi

if [ ! -e /usr/lib/libldap-2.3.so.0 ]; then
  ln -s /usr/lib/libldap-2.4.so.2 /usr/lib/libldap-2.3.so.0
fi

if [ ! -e /usr/lib/liblber-2.3.so.0 ]; then
  ln -s /usr/lib/liblber-2.4.so.2 /usr/lib/liblber-2.3.so.0
fi

if [ ! -d /var/lock/mgserver ]; then
  mkdir /var/lock/mgserver
fi


# Download Ubuntu packages for FDO
for file in core gdal kingoracle ogr postgis sdf shp sqlite wfs wms
do
  wget -N ${URL}/fdo-${file}_${FDOVER}.deb
done

# Download Ubuntu packages for MapGuide
for file in common server webextensions httpd
do
  wget -N ${URL}/mapguideopensource-${file}_${MGVER}.deb
done

# Download Ubuntu package for Maestro
wget -N ${URL}/mapguideopensource-maestro_${MAESTROVER}.deb

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

popd

