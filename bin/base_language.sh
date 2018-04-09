#!/bin/sh
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL version >= 2.1.
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
# This script will install additional language support
# Language choice was made based on the
# 1. SIL Ethnologue http://en.wikipedia.org/wiki/List_of_languages_by_number_of_native_speakers
# Note: Wu language not in the ISO list
# 2. Ubuntu Language packa available
# 3. OSGeo Chapter Presence ?
# TODO: find out which applications support which languages
#
# Running:
# =======
# Pick a different language at the login screen
#

./diskspace_probe.sh "`basename $0`" begin
####


# Start off with the Xfce keyboard layout configuration tool
### ubuntu 11.04: xfkc no longer exists:
#PACKAGES="xfkc"
PACKAGES=""

#Alternate list based on Live translations and OSGeo chapters
#https://spreadsheets.google.com/ccc?key=0AlRFyY1XenjJdFRDbjFyWHg1MlNTRm10QXk0UWEzWlE&hl=en
# English is assumed as the 1st language already installed
for CODE in \
 de \
 el \
 en \
 es \
 it \
 ja \
 pl \
 ro \
 fi \
 fr \
 he \
 hi \
 ko \
 pt \
 th \
 vi \
 zh-hant \
 ar \
 id \
 ru \
; do
  #Currently simulates in order to test for packages and how much space it will take
  #These meta packages also pull openoffice, so we'll have to do it the harder way
#PACKAGES="$PACKAGES language-support-$CODE language-pack-$CODE" 
PACKAGES="$PACKAGES language-pack-$CODE-base language-pack-$CODE"
  #Additional packages may have language packs specific to them ie: firefox	
done

#Seems to not find the packages without this, might just be a quirk of the test iso
apt-get -q update
apt-get install --assume-yes -q --no-install-recommends $PACKAGES


## experiment 6.5a4  generate the iso-8859-1x locale
## xenial - ref /usr/share/i18n/SUPPORTED
#locale-gen en_US iso88591
#locale-gen en_US iso885915
#dpkg-reconfigure locales


#TODO: allow select at boot splash screen


####
./diskspace_probe.sh "`basename $0`" end
