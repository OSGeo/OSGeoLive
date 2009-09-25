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

