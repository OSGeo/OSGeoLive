#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install MB-System
#    written by H.Bowman <hamish_b  yahoo com>
#    MB-System homepage: http://www.ldeo.columbia.edu/res/pi/MB-System/
#


### FIXME: install size currently 319 MB. Need to figure out how to build it
###   using shared libraries.
# http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html
#  ???
# CFLAGS += "-shared -fPIC"
# LFLAGS += "-shared -Wl,-soname,libmbio.so" ????
#  ???
# (but no luck)


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"


MB_VERSION="5.1.2"
LATEST="ftp://ftp.ldeo.columbia.edu/pub/MB-System/mbsystem-$MB_VERSION.tar.gz"


#### get dependencies ####

DEPENDS="gmt gv lesstif2 libnetcdf4 libgl1-mesa-glx libglu1-mesa csh proj libfftw3-3"
BUILD_DEPENDS="libgmt-dev lesstif2-dev libnetcdf-dev libglu1-mesa-dev libgl1-mesa-dev libfftw3-dev"

PACKAGES="$DEPENDS $BUILD_DEPENDS"


TO_INSTALL=""
for PACKAGE in $PACKAGES ; do
   if [ `dpkg -l $PACKAGE | grep -c '^ii'` -eq 0 ] ; then
      TO_INSTALL="$TO_INSTALL $PACKAGE"
   fi
done

if [ -n "$TO_INSTALL" ] ; then
   apt-get --assume-yes install $TO_INSTALL

   if [ $? -ne 0 ] ; then
      echo "ERROR: package install failed: $TO_INSTALL"
      exit 1
   fi
fi


# add GMT apps to the PATH if needed
if [ `grep -c '/usr/lib/gmt/bin' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   echo 'PATH="$PATH:/usr/lib/gmt/bin"' >> "$USER_HOME/.bashrc"
fi


mkdir -p /tmp/build_mbsystem
cd /tmp/build_mbsystem

#### get tarball ####

if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

wget -c --progress=dot:mega "$LATEST"

tar xzf `basename $LATEST`

#if [ $? -eq 0 ] ; then
#   \rm `basename $LATEST`
#fi


### get the Levitus annual water temperature profile database
# needed for mblevitus program, uncompressed it is 16mb.
wget -c --progress=dot:mega ftp://ftp.ldeo.columbia.edu/pub/MB-System/annual.gz

gzip -d annual.gz
#if [ $? -eq 0 ] ; then
#   \rm annual.gz
#fi
\mv annual LevitusAnnual82.dat


cd `basename $LATEST .tar.gz`



#### config build ####

PATCH="install_makefiles.Lenny"
wget -nv "https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/arramagong_3/app-data/mb-system/$PATCH.patch" \
       -O "$PATCH.patch"
patch -p0 < "$PATCH.patch"

./install_makefiles

make all


#### install ####
install bin/* /usr/local/bin
install --mode=644 lib/* /usr/local/lib
mkdir -p /usr/local/man/man1
install --mode=644 man/man1/* /usr/local/man/man1
mkdir -p /usr/local/man/man3
install --mode=644 man/man3/* /usr/local/man/man3
for SUBDIR in  html include ps share ; do
   mkdir -p /usr/local/mbsystem/$SUBDIR
   install --mode=644 $SUBDIR/* /usr/local/mbsystem/$SUBDIR
done
install --mode=644 ../LevitusAnnual82.dat /usr/local/mbsystem/share


### cleanup ####
make clean
apt-get --assume-yes remove $BUILD_DEPENDS
# not sure why this isn't happening automatically anymore,
apt-get --assume-yes autoremove

cd ..


# add /usr/local/lib to /etc/ld.so.conf if needed, then run ldconfig
# FIXME: similar thing needed for man pages?
# FIXME: not needed until we figure out how to make shared libs?
if [ -d /etc/ld.so.conf.d ] ; then
   echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
else
   if [ `grep -c '/usr/local/lib' /etc/ld.so.conf` -eq 0 ] ; then
      echo "/usr/local/lib" >> /etc/ld.so.conf
   fi
fi
ldconfig


#### user config ####
if [ `grep -c 'MB_PS_VIEWER=' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   echo "export MB_PS_VIEWER=gv" >> "$USER_HOME/.bashrc"
fi



#### get and install sample data ####
# ftp://ftp.ldeo.columbia.edu/pub/MB-System/
#
# On 31 Aug 2009, Dave Caress wrote:
# The cookbook example data tends towards old and deep water - I'll try to
# assemble samples of current systems covering a range of altitudes, but
# it won't be available this week.
# Cheers,
# Dave

cd /tmp/build_mbsystem

wget -c --progress=dot:mega ftp://ftp.ldeo.columbia.edu/pub/MB-System/MB-SystemExamples.5.1.0.tar.gz

cd /usr/local/mbsystem/
tar xzf /tmp/build_mbsystem/MB-SystemExamples.5.1.0.tar.gz
mv MB-SystemExamples.5.1.0/ examples/
chmod -R g+w examples/
chown -R root.users examples/
adduser $USER_NAME users


#### get and install cookbook tutorial ####

cd /tmp/build_mbsystem
wget -c --progress=dot:mega ftp://ftp.ldeo.columbia.edu/pub/MB-System/mbcookbook.pdf
cp mbcookbook.pdf /usr/local/mbsystem/



echo "Finished installing MB System."

