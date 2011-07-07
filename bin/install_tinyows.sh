#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install tinyows in xubuntu

# Running:
# =======
# sudo ./install_tinyows.sh

USER_NAME="user"
USER_HOME="/home/$USER_NAME"

#Add repositories
cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  

apt-get update

#Install packages
apt-get --assume-yes install tinyows

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi

#Setup sample config
sudo cp ../app-conf/tinyows/tinyows.xml /etc/
