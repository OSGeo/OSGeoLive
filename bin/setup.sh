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

# Install some useful stuff
apt-get install wget more less zip unzip bzip2 \
  cvs cvsutils subversion subversion-tools bzr bzr-tools \
  openssh-client lftp sl smbclient usbutils wireless-tools \
  locate diff patch fuseiso \
  vim emacs nedit nano \
  evince ghostscript a2ps pdftk netpbm qiv \
  lynx mutt mc xchat rxvt units

# Uninstall default applications
apt-get uninstall gnome-games

