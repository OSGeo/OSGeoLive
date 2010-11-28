#!/bin/sh
#################################################
# 
# Purpose: Provide a csv list of document version numbers and related fields
# Author:  Cameron Shorter
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
#
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
##################################################


# cd to the svn document directory
cd `dirname ${0}`/../doc

echo "dir/file,docname,version,directory,language,username,project,last updated:" `date`

#List doc svn version numbers
#  svn list -v -R \
#Only look at rst source docs
# | grep ".rst$" \
#Ignore doc/index.rst which is just an autoforward to doc/en/index.rst
# | grep -v " index.rst$" \
#Ignore directories
# | grep -v "/$"  \
#Change en/contact.rst to en/./contact.rst (so all files have 2 dirs)
# | sed -e's#\( [^/]*\)/\([^/]*$\)#\1/./\2#' \
#Insert space delimiters between dirs
# | sed -e's#/# #g' \
#Reorder and insert commas
# | awk '{print $9","$1","$8","$7","$2","$9}' \
# change . to "." so that it is read as a string instead of number
# | sed -e's/,\.,/,".",/' \
#Extract project name from filename
# | sed -e's/_overview.rst$//' \
# | sed -e's/_quickstart.rst$//' \
# | sed -e's/.rst$//' \


#cat list.txt \
svn list -v -R \
  | grep ".rst$" \
  | grep -v " index.rst$" \
  | grep -v "/$"  \
  | sed -e's#\( [^/]*\)/\([^/]*$\)#\1/./\2#' \
  | sed -e's#/# #g' \
  | awk '{print $7"/"$8"/"$9","$9","$1","$8","$7","$2","$9}' \
  | sed -e's/,\.,/,".",/' \
  | sed -e's/_overview.rst$//' \
  | sed -e's/_quickstart.rst$//' \
  | sed -e's/.rst$//' \

