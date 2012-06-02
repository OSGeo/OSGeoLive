#!/bin/sh
#
# install_saga.sh
# 
#
# Created by Johan Van de Wauw on 2010-07-02
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# lucid: saga 2.0.4 is provided in ubuntugis and ubuntugis/unstable

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

# # Add repositories
# cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/
# 
# #Add signed key for repositorys LTS and non-LTS
# #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF
# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
apt-add-repository --yes ppa:johanvdw/saga-gis

apt-get update
apt-get --assume-yes install saga libsaga

# Additional documentation
mkdir -p /usr/local/share/saga
cd /usr/local/share/saga
wget -c --progress=dot:mega \
  http://sourceforge.net/projects/saga-gis/files/SAGA%20-%20Documentation/SAGA%202%20User%20Guide/SAGA2_UserGuide_Cimmery_20070401.pdf/download

# Demo dataset
wget -N --progress=dot:mega \
  http://zadeh.ugent.be/~johan/saga/DGM_30m_Mt.St.Helens_SRTM.grd
# Link demo dataset to user_home
ln -s /usr/local/share/saga/ $USER_HOME/saga

# Desktop icon
# temporarily disabled: a custom .desktop file with a 64x64 logo is used - to be fixed in the package
wget -nv http://zadeh.ugent.be/~johan/saga/saga_gui_64x64.png \
   --output-document=/usr/share/pixmaps/saga_gui_64x64.png
wget -nv http://zadeh.ugent.be/~johan/saga/saga_gui.desktop \
   --output-document=/usr/share/applications/saga_gui.desktop

cp /usr/share/applications/saga_gui.desktop "$USER_HOME/Desktop/"
chown "$USER_NAME:$USER_NAME" "$USER_HOME/Desktop/saga_gui.desktop"
