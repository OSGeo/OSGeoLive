#!/usr/bin/perl

use XBase;

$file = 'airports';
         
$table = new XBase "$file.dbf" or die XBase->errstr;

@items = $table->field_names();

# query header
open(STREAM, ">". $file ."_header.html") or die "Unable to open query header.\n";
print STREAM "<font size+1><b>Layer: $file</b></font><p>\n";
print STREAM "<table cellpadding=5 cellspacing=2 border=0>\n";
print STREAM "<tr bgcolor=#CCCCCC>";
foreach (@items) {
  print STREAM "<th>". $_ ."</th>";
}
print STREAM "</tr>\n";
close(STREAM);

# query template
open(STREAM, ">". $file .".html") or die "Unable to open query template.\n";
print STREAM "<tr>";
foreach (@items) {
  print STREAM "<td>[". $_ ."]</td>";
}
print STREAM "</tr>\n";
close(STREAM);

# query footer
open(STREAM, ">". $file ."_footer.html") or die "Unable to open query footer.\n";
print STREAM "</table><p>\n";
close(STREAM);

$table->close();
