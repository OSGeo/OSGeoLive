#!/bin/sh
#
# install_saga.sh
# 
#
# Created by Johan Van de Wauw on 2010-07-02
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# lucid: saga 2.0.4 is provided in ubuntugis and ubuntugis/unstable
# maverick: saga 2.0.4 is provided in universe

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

# Add repositories
cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160

apt-get update
apt-get --assume-yes install saga libsaga

# Additional documentation
mkdir -p /usr/local/share/saga
cd /usr/local/share/saga
wget -c --progress=dot:mega \
  http://sourceforge.net/projects/saga-gis/files/SAGA%20-%20Documentation/SAGA%202%20User%20Guide/SAGA2_UserGuide_Cimmery_20070401.pdf/download

# Desktop icon
cp /usr/share/applications/saga_gui.desktop "$USER_HOME/Desktop/"

