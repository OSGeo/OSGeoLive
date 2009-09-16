#!/usr/bin/perl

use XBase;
use mapscript;

sub clean() {
  my ($file) = @_;

  foreach $extension ('.shp', '.shx', '.dbf', '.qix') {    
    unlink $file.$extension;
  }
}

&clean('airports');

$shapefile = new shapefileObj("airports", 1) or die("Error creating shapefile airports.");
$table = XBase->create("name" => "airports",
		       "field_names" => ["NAME", "LAT", "LON", "ELEVATION", "QUADNAME"],
		       "field_types" => ["C", "N", "N", "N", "C"],
		       "field_lengths" => [64, 12, 12, 12, 32],
		       "field_decimals" => [0, 4, 4, 4, 0]) or die XBase->errstr;

$point = new pointObj();

$point->{x} = 451306.0000; 
$point->{y} = 5291930.0000;
$shapefile->addPoint($point);
$table->set_record(0, 'Bigfork Municipal Airport', 47.7789, -93.6500, 1343.0000, 'Effie');

$point->{x} = 469137.0000; 
$point->{y} = 5271647.0000;
$shapefile->addPoint($point);
$table->set_record(1, 'Bolduc Seaplane Base', 47.5975, -93.4106, 1325.0000, 'Balsam Lake');

$point->{x} = 434634.0000; 
$point->{y} = 5267578.0000;
$shapefile->addPoint($point);
$table->set_record(2, 'Bowstring Municipal Airport', 47.5583, -93.8689, 1372.0000, 'Jessie Lake');

$point->{x} = 454146.0000; 
$point->{y} = 5274617.0000;
$shapefile->addPoint($point);
$table->set_record(3, 'Burns Lake Seaplane Base', 47.6233, -93.6103, 1357.0000, 'Clubhouse Lake');

$point->{x} = 495913.0000; 
$point->{y} = 5279532.0000;
$shapefile->addPoint($point);
$table->set_record(4, 'Christenson Point Seaplane Base', 47.6692, -93.0544, 1372.0000, 'Side Lake');

$point->{x} = 439581.0000; 
$point->{y} = 5244617.0000;
$shapefile->addPoint($point);
$table->set_record(5, 'Deer River Municipal Airport', 47.3522, -93.8000, 1311.0000, 'Deer River');

$point->{x} = 493040.0000; 
$point->{y} = 5230604.0000;
$shapefile->addPoint($point);
$table->set_record(6, 'Gospel Ranch Airport', 47.2289, -93.0919, 1394.0000, 'Floodwood Lake');

$point->{x} = 461401.0000; 
$point->{y} = 5228719.0000;
$shapefile->addPoint($point);
$table->set_record(7, 'Grand Rapids-Itasca County/Gordon Newstrom Field', 47.2108, -93.5097, 1355.0000, 'Grand Rapids');

$point->{x} = 455305.0000; 
$point->{y} = 5240463.0000;
$shapefile->addPoint($point);
$table->set_record(8, 'Richter Ranch Airport', 47.3161, -93.5914, 1340.0000, 'Cohasset East');

$point->{x} = 471043.0000; 
$point->{y} = 5251664.0000;
$shapefile->addPoint($point);
$table->set_record(9, 'Shaughnessy Seaplane Base', 47.4178, -93.3839, 1300.0000, 'Lawrence Lake West');

$point->{x} = 496393.0000;
$point->{y} = 5280458.0000;
$shapefile->addPoint($point);
$table->set_record(10, 'Sixberrys Landing Seaplane Base', 47.6775, -93.0481, 1372.0000, 'Side Lake');

$point->{x} = 444049.0000;
$point->{y} = 5277360.0000;
$shapefile->addPoint($point);
$table->set_record(11, 'Snells Seaplane Base', 47.6472, -93.7450, 1351.0000, 'Bigfork');

$table->close(); # save the files
undef $shapefile;

exit 0;
