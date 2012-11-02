#!/usr/bin/perl
###############################################################################
# 
# Purpose: Provide translation status of OSGeoLive docs, extracted from svn
# Author:  Cameron Shorter
#
###############################################################################
# Copyright (c) 2012 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2012 LISAsoft
# Copyright (c) 2012 Cameron Shorter
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
###############################################################################

use strict;
use warnings;
use File::Basename;

# initialise variables
my $osgeolive_docs_url="http://adhoc.osgeo.osuosl.org/livedvd/docs/";
my %svninfo;
my $line;

&extract_svn_info;
&printhtml;


###############################################################################
# Extract subversion information for osgeo-live document files and store in
# a hash array @svnlist
###############################################################################
sub extract_svn_info() {
  # Store the script root directory for later
  my $scriptDir = dirname($0);

  # cd to the svn document directory
  #chdir("$scriptDir/../doc");

  #my @svnlist = split(/\n/, `svn list -v -R`);
  my @svnlist = split(/\n/, `cat list.txt`);

  foreach (@svnlist) {
    my $line2=$_;
    if (
      m#/# # Ignore files in the root directory
      && m/.rst$/ # Only look at rst source docs
      && ! m/template_/ # The template files have been removed from subversion, but are still pickedup by svn list.
    ) {
      $line = $_;

      #Change en/contact.rst to en/./contact.rst (so all files have 2 dirs)
      $line =~ s#( [^/]*)/([^/]*$)#$1/./$2#;

      #Insert space delimiters between dirs
      $line =~ s#/# #g;

      my @args = split /\s+/, $line;
      my $lang=$args[7];
      my $dir_file="$args[8]/$args[9]";

      # Extract info into a hash array
      $svninfo{$lang}{$dir_file}{"version"}=$args[1];
      $svninfo{$lang}{$dir_file}{"author"}=$args[2];
      $svninfo{$lang}{$dir_file}{"date"}="$args[4] $args[5] $args[6]";
      $svninfo{$lang}{$dir_file}{"dir"}=$args[8];
      $svninfo{$lang}{$dir_file}{"file"}=$args[9];
    }
  }
}

###############################################################################
# Print table showing file versions for each language
###############################################################################
sub printhtml() {

  print "<table border='1'>\n";
  print "<tr><th>dir/file</th><th>date</th><th>en</th>";
  foreach my $lang (sort keys %svninfo) {
    $lang =~ /en/ && next;
    print "<th>$lang</th>";
  }
  print "</tr>\n";

  # loop through filenames
  foreach my $dir_file (sort keys $svninfo{"en"}) {

    # print file/dir and url
    my $html_file=$svninfo{'en'}{$dir_file}{'file'};
    $html_file=~s#.rst$#.html#;
    print "<tr><td>";
    print "<a href='$osgeolive_docs_url/en/";
    print "$svninfo{'en'}{$dir_file}{'dir'}/$html_file'>";
    print "$dir_file</a></td>";

    # print date
    print "<td>$svninfo{'en'}{$dir_file}{'date'}</td>";

    # print english version
    print "<td>$svninfo{'en'}{$dir_file}{'version'}</td>";

    # loop through languages
    foreach my $lang (sort keys %svninfo) {
      $lang =~ /en/ && next;

      # print language's version
      print "<td>";
      if (exists $svninfo{$lang}{$dir_file} ) {
        if ($svninfo{$lang}{$dir_file}{'version'} >= $svninfo{"en"}{$dir_file}{'version'}) {
          print '<font color="green">';
          print "$svninfo{$lang}{$dir_file}{'version'}";
          print "</font>";
        }else{

          # create a URL for the diff in en doc since last translated
          # Eg: http://trac.osgeo.org/osgeo/changeset?new=9055%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fde%2Foverview%2F52nSOS_overview.rst&old=9054%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fde%2Foverview%2F52nSOS_overview.rst
          my $url="http://trac.osgeo.org/osgeo/changeset?new=";
          $url .= $svninfo{'en'}{$dir_file}{'version'};
          $url .= "%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fen%2F";
          if (!$svninfo{'en'}{$dir_file}{'dir'}=~m/^\.$/) {
            $url .= $svninfo{'en'}{$dir_file}{'dir'};
          }
          $url .= "%2F";
          $url .= $svninfo{'en'}{$dir_file}{'file'};
          $url .= "&old=";
          $url .= $svninfo{$lang}{$dir_file}{'version'};
          $url .= "%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fen%2F";
          if (!$svninfo{'en'}{$dir_file}{'dir'}=~m/^\.$/) {
            $url .= $svninfo{'en'}{$dir_file}{'dir'};
          }
          $url .= "%2F";
          $url .= $svninfo{'en'}{$dir_file}{'file'};

          print "<a href='$url'>";
          print "$svninfo{$lang}{$dir_file}{'version'}";
          print "</a>";
        }
      }
      print "</td>";
    }
    print "</tr>\n";
  }
  print "\n</table>\n";
}
