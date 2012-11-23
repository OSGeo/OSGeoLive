#!/usr/bin/perl
###############################################################################
# 
# Purpose: Provide translation status of OSGeoLive docs, extracted from svn
# Author:  Cameron Shorter
# Usage: extract_doc_versions -o outputfile.html
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
use Getopt::Std;

# initialise variables
my $osgeolive_docs_url="http://adhoc.osgeo.osuosl.org/livedvd/docs/";
my %svninfo;
my $line;

# Get output file from the -o option, otherwise print to stdout
my %options=();
getopts("o:", \%options);
my $outfile = *STDOUT;
if ($options{o}) {
  open $outfile, ">", $options{o} || die "can't open output file $options{o}: $!\n";
}

&extract_svn_info;
#&extract_review_status;
&print_header;
&print_summary;
&print_lang_versions;
&print_footer;

###############################################################################
# Print Header html
###############################################################################
sub print_header() {
  print $outfile "<html>\n";
  print $outfile "  <head>\n";
  print $outfile "    <title>OSGeo-Live Documentation translation status</title>\n";
  print $outfile "  </head>\n";
  print $outfile "  <body>\n";
  print $outfile "    <h1>OSGeo-Live Documentation translation status</h1>\n";
  print $outfile "    <p>Help translate - <a href='http://wiki.osgeo.org/wiki/Live_GIS_Translate'>click here!</a></p>\n";
  print $outfile "    <p><b>Last Updated:</b> ", `date`;
  print $outfile ". This page is calculated from document version numbers in subversion.</p>\n";
}

###############################################################################
# Print Footer html
###############################################################################
sub print_footer() {
  print $outfile "  </body>";
  print $outfile "</html>";
}

###############################################################################
# Extract subversion information for osgeo-live document files and store in
# a hash array @svnlist
###############################################################################
sub extract_svn_info() {
  # Store the script root directory for later
  my $scriptDir = dirname($0);

  #my @svnlist = split(/\n/, `cat list.txt`);

  # cd to the svn document directory
  chdir("$scriptDir/../doc");

  # update to the latest version of docs
  `svn update`;
  my @svnlist = split(/\n/, `svn list -v -R`);

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
# Extract Overview and Quickstart written and review status from Google
# Spreadsheet
###############################################################################
#sub extract_review_status() {
#  my $csv = Text::CSV->new();
#  my $google_doc_status_csv="https://docs.google.com/feeds/download/spreadsheets/Export?exportFormat=tsv&key=0Al9zh8DjmU_RdGIzd0VLLTBpQVJuNVlHMlBWSDhKLXc#gid=13"
#
#  open (my $file, "<", $google_doc_status_csv) or die $!;
#
#  while (my $line = <$file>) {
#    my @columns = split(/\t/, $line);
#    print "@columns\n";
#  }
#  close $file;
#}

###############################################################################
# Summarise tranlation status
###############################################################################
sub print_summary() {

  print $outfile "<a name='summary'/><h2>Summary</h2>\n";
  print $outfile "<table border='1'>\n";
  print $outfile "<tr><th>language</th><th>Sum up to date</th><th>Sum translated</th></tr>\n";

  # number of english files to translate
  my $sum_files=scalar keys %{$svninfo{"en"}};

  # loop through languages
  foreach my $lang (sort keys %svninfo) {
    # loop through filenames
    my $up_to_date=0;
    foreach my $dir_file (keys %{$svninfo{"en"}}) {
      if (exists $svninfo{$lang}{$dir_file}) {
        if ($svninfo{$lang}{$dir_file}{'version'} >= $svninfo{"en"}{$dir_file}{'version'}) {
          $up_to_date++;
        }
      }
    }
    my $translations=scalar keys %{$svninfo{$lang}};
    my $translations_percent=int($translations*100/$sum_files);
    my $up_to_date_percent=int($up_to_date*100/$sum_files);
    print $outfile "<tr><td>$lang</td><td>$up_to_date ($up_to_date_percent%)</td>";
    print $outfile "<td>$translations ($translations_percent%)</td></tr>\n";
  }
  print $outfile "</table>\n";
}

###############################################################################
# print table showing file versions for each language
###############################################################################
sub print_lang_versions() {

  print $outfile "<a name='lang_versions'/><h2>Per file translation status</h2>\n";
  print $outfile "<p>Hyperlinks point to the difference in the English document since last translated.</p>\n";
  print $outfile "<table border='1'>\n";
  print $outfile "<tr><th>dir/file</th><th>date</th><th>en</th>\n";
  foreach my $lang (sort keys %svninfo) {
    $lang =~ /en/ && next;
    print $outfile "<th>$lang</th>";
  }
  print $outfile "</tr>\n";

  # loop through filenames
  foreach my $dir_file (sort keys %{$svninfo{"en"}}) {

    # print file/dir and url
    my $html_file=$svninfo{'en'}{$dir_file}{'file'};
    $html_file=~s#.rst$#.html#;
    print $outfile "<tr><td>";
    print $outfile "<a href='$osgeolive_docs_url/en/";
    print $outfile "$svninfo{'en'}{$dir_file}{'dir'}/$html_file'>";
    print $outfile "$dir_file</a></td>";

    # print date
    print $outfile "<td>$svninfo{'en'}{$dir_file}{'date'}</td>";

    # print english version
    print $outfile "<td>$svninfo{'en'}{$dir_file}{'version'}</td>";

    # loop through languages
    foreach my $lang (sort keys %svninfo) {
      $lang =~ /en/ && next;

      # print language's version
      print $outfile "<td>";
      if (exists $svninfo{$lang}{$dir_file} ) {
        if ($svninfo{$lang}{$dir_file}{'version'} >= $svninfo{"en"}{$dir_file}{'version'}) {
          print $outfile '<font color="green">';
          print $outfile "$svninfo{$lang}{$dir_file}{'version'}";
          print $outfile "</font>";
        }else{

          # create a URL for the diff in en doc since last translated
          # Eg: http://trac.osgeo.org/osgeo/changeset?new=9055%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fde%2Foverview%2F52nSOS_overview.rst&old=9054%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fde%2Foverview%2F52nSOS_overview.rst
          my $url="http://trac.osgeo.org/osgeo/changeset?new=";
          $url .= $svninfo{'en'}{$dir_file}{'version'};
          $url .= "%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fen%2F";
          if (!($svninfo{'en'}{$dir_file}{'dir'} eq ".")) {
            $url .= $svninfo{'en'}{$dir_file}{'dir'};
            $url .= "%2F";
          }
          $url .= $svninfo{'en'}{$dir_file}{'file'};
          $url .= "&old=";
          $url .= $svninfo{$lang}{$dir_file}{'version'};
          $url .= "%40livedvd%2Fgisvm%2Ftrunk%2Fdoc%2Fen%2F";
          if (!($svninfo{'en'}{$dir_file}{'dir'} eq ".")) {
            $url .= $svninfo{'en'}{$dir_file}{'dir'};
            $url .= "%2F";
          }
          $url .= $svninfo{'en'}{$dir_file}{'file'};

          print $outfile "<a href='$url'>";
          print $outfile "$svninfo{$lang}{$dir_file}{'version'}";
          print $outfile "</a>";
        }
      }
      print $outfile "</td>";
    }
    print $outfile "</tr>\n";
  }
  print $outfile "</table>\n";
}

