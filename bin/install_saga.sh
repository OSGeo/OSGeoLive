#!/bin/sh
#
# install_saga.sh
#
# Created by Johan Van de Wauw on 2010-07-02
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# This script licensed under the GNU LGPL version >= 2.1.

./diskspace_probe.sh "`basename $0`" begin
####
BUILD_DIR=`pwd`

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

apt-get -q update
apt-get --assume-yes install saga libsaga

# Additional documentation
mkdir -p /usr/local/share/saga
cd /usr/local/share/saga

# Demo dataset
wget -N --progress=dot:mega \
   "http://downloads.sourceforge.net/project/saga-gis/SAGA%20-%20Demo%20Data/Demo%20Data%20for%20SAGA/DGM_30m_Mt.St.Helens_SRTM.zip"
unzip DGM_30m_Mt.St.Helens_SRTM.zip
rm -f DGM_30m_Mt.St.Helens_SRTM.zip

# Link demo dataset to user_home
ln -s /usr/local/share/saga "$USER_HOME"/saga
ln -s /usr/local/share/saga /etc/skel/saga
 
 
# Desktop icon
cp /usr/share/applications/saga.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/saga.desktop"

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
