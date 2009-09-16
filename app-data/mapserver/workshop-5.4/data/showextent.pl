#!/usr/bin/perl

use mapscript;

$buffer = .10;

$shapefile = new shapefileObj('mcd90py2', -1) or die('Unable to open mcd90py2');
print $shapefile->{bounds}->{minx} ." ". $shapefile->{bounds}->{miny} ." ". $shapefile->{bounds}->{maxx} ." ". $shapefile->{bounds}->{maxy} ."\n";

$dx = ($shapefile->{bounds}->{maxx} - $shapefile->{bounds}->{minx})*$buffer*.5;
$dy = ($shapefile->{bounds}->{maxy} - $shapefile->{bounds}->{miny})*$buffer*.5;

$minx = $shapefile->{bounds}->{minx} - $dx;
$maxx = $shapefile->{bounds}->{maxx} + $dx;
$miny = $shapefile->{bounds}->{miny} - $dy;
$maxy = $shapefile->{bounds}->{maxy} + $dy;

print $minx ." ". $miny ." ". $maxx ." ". $maxy ."\n";

undef $shapefile;
