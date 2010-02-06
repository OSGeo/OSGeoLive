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
# This script will install additional language support
# Language choice was made based on the 
# 1. SIL Ethnologue http://en.wikipedia.org/wiki/List_of_languages_by_number_of_native_speakers
# 2. Ubuntu Language packa available
# 3. OSGeo Chapter Presence ?
# TODO: find out which applications support which languages
#
# Running:
# =======
# Pick a different language at the login screen
#
PACKAGES=""

#TODO: make an alternate list base on OSGeo chapters
for CODE in \
  zh \ #Chinese(Mandarin) 
  sp \ #Spanish 
  en \ #English 
  hi \ #Hindi/Urdu
  ar \ #Arabic 
  bn \ #Bengali
  pt \ #Portuguese 
  ru \ #Russian
  ja \ #Japanese
  de \ #German
  jv \ #Javanese
  pa \ #Punjabi pa
# no language code for Wu may not be a written language
  fr \ #French 
  te \ #Telugu
  vi \ #Vietnamese
  mr \ #Marathi
  ko \ #Korean
  ta \ #Tamil
  it \ #Italian
  tr \ #Turkish
; do
  #Currently simulates in order to test for packages and how much space it will take
PACKAGES="$PACKAGES language-support-$code" 
  #Additional packages may have language packs specific to them ie: firefox	
done
apt-get install -s $PACKAGES

#TODO: allow select at boot splash screen

