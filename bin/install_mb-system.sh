#!/bin/sh
# Copyright (c) 2009-2013 The Open Source Geospatial Foundation.
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
#    DebianGIS packaging: http://anonscm.debian.org/viewvc/pkg-grass/packages/mbsystem/trunk/debian/

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


VERS="5.4.2128-0"


#### get dependencies ####

PACKAGES="gmt gv lesstif2 libnetcdf6 libgl1-mesa-glx libglu1-mesa
          csh proj libfftw3-3 libparallel-forkmanager-perl"

apt-get --assume-yes install $PACKAGES


# add GMT apps to the PATH if needed
if [ `grep -c '/usr/lib/gmt/bin' "$USER_HOME/.bashrc"` -eq 0 ] && \
   [ ! -e /etc/profile.d/gmt_path.sh ] ; then
      echo 'PATH="$PATH:/usr/lib/gmt/bin"' >> "$USER_HOME/.bashrc"
fi


mkdir -p /tmp/build_mbsystem
cd /tmp/build_mbsystem

#### get tarball ####

if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

DL_URL="http://download.osgeo.org/livedvd/data/mbsystem/precise/i386"

for file in mbsystem_${VERS}_i386.deb \
            mbsystem-doc_${VERS}_all.deb \
            mbsystem-data_${VERS}_all.deb ; do

   wget -c --progress=dot:mega "$DL_URL/$file"
   if [ $? -ne 0 ] ; then
      echo "Download error on <$file>. Aborting."
      exit 1
   fi

   gdebi --non-interactive --quiet "$file"
   if [ $? -ne 0 ] ; then
      echo "Install error on <$file>. Aborting."
      exit 1
   fi
done


#### user config ####
if [ `grep -c 'MB_PS_VIEWER=' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   echo "export MB_PS_VIEWER=gv" >> "$USER_HOME/.bashrc"
fi
if [ `grep -c 'MB_PS_VIEWER=' "/etc/skel/.bashrc"` -eq 0 ] ; then
   echo "export MB_PS_VIEWER=gv" >> "/etc/skel/.bashrc"
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

# symlink into the livedvd's common data dir
ln -s /usr/local/mbsystem /usr/local/share/mbsystem


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
