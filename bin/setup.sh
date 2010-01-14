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
# This script will take a raw Xubuntu system and update it ready to run
# GISVM install scripts.

# Running:
# =======
# sudo ./setup.sh

if [ "`uname -m`" != "i686" ] ; then
   echo "WARNING: Current system is not i686; any binaries built may be tied to current system (`uname -m`)"
fi
# look for ./configure --build=BUILD, --host=HOST, --target=TARGET  to try and force build for i686.
# For .deb package building something like: 'debuild binary-arch i686' ???????


# Install latest greatest security packages etc.
apt-get update && apt-get --yes upgrade


# Add UbuntuGIS repository
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/sources.list.d/ubuntugis.list \
     --output-document=/etc/apt/sources.list.d/ubuntugis.list
#Add signed key for repositorys LTS and non-LTS
#qgis repo 68436DDF unused? :
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  
apt-get update


# Install some useful stuff
apt-get install --yes wget less zip unzip bzip2 p7zip \
  cvs cvsutils subversion subversion-tools bzr bzrtools git mercurial \
  openssh-client lftp sl smbclient usbutils wireless-tools \
  locate diff patch fuseiso menu \
  vim emacs nedit nano screen \
  evince ghostscript a2ps pdftk netpbm qiv \
  lynx mutt mc xchat rxvt units

# Install build stuff (temporarily?)
apt-get install --yes gcc build-essential devscripts pbuilder fakeroot \
  cvs-buildpackage svn-buildpackage lintian debhelper pkg-config


# Uninstall default applications
apt-get remove --yes gnome-games

# Remove unused home directories
rm -fr /home/user/Documents
rm -fr /home/user/Music
rm -fr /home/user/Pictures
rm -fr /home/user/Templates
rm -fr /home/user/Videos

# rename dangerous icon
# this probably won't work here because ubiquity isn't loaded until remastersys step
sed -i -e 's/Install/Install xubuntu GNU Linux/' /usr/share/applications/ubiquity-gtkui.desktop


# and there was music and laughter and much rejoicing
adduser user audio

# highly useful tricks
echo "alias ll='ls -l'" >> /home/user/.bashrc
chown user.user /home/user/.bashrc

cat << EOF >> /home/user/.inputrc
# a conference talk full of terminal beeps is no good
set prefer-visible-bell

# -------- Bind page up/down wih history search ---------
"\e[5~": history-search-backward
"\e[6~": history-search-forward
EOF
chown user.user /home/user/.inputrc
