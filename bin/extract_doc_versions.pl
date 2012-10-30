#!/usr/bin/perl
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

# This script extracts out the subversion version of osgeo-live documents in
# a format suitable to be copied into the OSGeo-Live translation status
# stored here:
# https://spreadsheets.google.com/ccc?key=0AlRFyY1XenjJdFRDbjFyWHg1MlNTRm10QXk0UWEzWlE&hl=en_GB&authkey=CPTB6uIE#gid=7

use strict;
use warnings;
use File::Basename;

# Store the script root directory for later
my $scriptDir = dirname($0);

# cd to the svn document directory
#chdir("$scriptDir/../doc");

#my $pwd=cwd();
#print("pwd=",$pwd);
#cd "$scriptDir";
#print "Fred:",`pwd`;

#my @lines = split /\n/, $svnlist;
#print @lines;


# Store the script root directory for later
#cd `dirname ${0}`
#scriptDir=`pwd`

# cd to the svn document directory
#cd ${scriptDir}/../doc

#echo "dir/file,docname,version,directory,language,username,date,project,last updated:" `date`

#my @svnlist = split(/\n/, `svn list -v -R`);
#my @svnlist = split(/\n/, `cat list.txt`);
my @svnlist = split(/\n/, `cat short.txt`);
my $line;
foreach (@svnlist) {
  if (
    m/.rst$/ # Only look at rst source docs
    && ! m/template_/ # The template files have been removed from subversion, but are still pickedup by svn list.
    && ! m/ index.rst$/ #Ignore doc/index.rst which is just an autoforward to doc/en/index.rst
  ) {
    $line = $_;
    $line =~ s/en/enn/;
    #&& s#\( [^/]*\)/\([^/]*$\)#\1/./\2# #Change en/contact.rst to en/./contact.rst (so all files have 2 dirs)
#Insert space delimiters between dirs
# | sed -e's#/# #g' \
#Reorder and insert commas
# | awk '{print $7"/"$8"/"$9","$9","$1","$8","$7","$2","$9,",",$4," ",$5," ",$6}' \
# change . to "." so that it is read as a string instead of number
# | sed -e's/,\.,/,".",/' \
#Extract project name from filename
# | sed -e's/_overview.rst$//' \
# | sed -e's/_quickstart.rst$//' \
# | sed -e's/.rst$//' \
    print "$line\n";
  }
}
exit

##cat list.txt \
#List doc svn version numbers
#  svn list -v -R \
#Only look at rst source docs
# | grep ".rst$" \
# The template files have been removed from subversion, but are still picked
# up by svn list.
# | grep -v "/template_" \
#Ignore doc/index.rst which is just an autoforward to doc/en/index.rst
# | grep -v " index.rst$" \
#Ignore directories
# | grep -v "/$"  \
#Change en/contact.rst to en/./contact.rst (so all files have 2 dirs)
# | sed -e's#\( [^/]*\)/\([^/]*$\)#\1/./\2#' \
#Insert space delimiters between dirs
# | sed -e's#/# #g' \
#Reorder and insert commas
# | awk '{print $7"/"$8"/"$9","$9","$1","$8","$7","$2","$9,",",$4," ",$5," ",$6}' \
# change . to "." so that it is read as a string instead of number
# | sed -e's/,\.,/,".",/' \
#Extract project name from filename
# | sed -e's/_overview.rst$//' \
# | sed -e's/_quickstart.rst$//' \
# | sed -e's/.rst$//' \


#svn list -v -R \
#  | grep ".rst$" \
#  | grep -v "/template_" \
#  | grep -v " index.rst$" \
#  | grep -v "/$"  \
#  | sed -e's#\( [^/]*\)/\([^/]*$\)#\1/./\2#' \
#  | sed -e's#/# #g' \
#  | awk '{print $8"/"$9"/"$10","$10","$1","$9","$8","$2",",$4,$5,$6,$7","$10}' \
#  | sed -e's/,\.,/,".",/' \
#  | sed -e's/_overview.rst$//' \
#  | sed -e's/_quickstart.rst$//' \
#  | sed -e's/.rst$//' \

# cd to the svn bin directory
#cd ${scriptDir}

#echo "INSTALL SCRIPTS:"
#echo "dir/file,docname,version,directory,language,username,date,project,last updated:" `date`

#cat list2.txt \
#ols line was | awk '{print "bin/"$7","$7","$1",bin,,"$2","$4" "$5" "$6","$7}' \
#svn list -v -R \
#  | grep -v "/$"  \
#  | awk '{print "bin/"$8","$8","$1",bin,,"$2","$4" "$5" "$6,$7","$8}' \
#  | sed -e's#,install_\([^,]*\).sh$#,\1#' \
#  | sed -e's/,\.,/,".",/' \
#  #| sed -e's#\(install_\)\([^,]*[.sh$\)#\2#' \
