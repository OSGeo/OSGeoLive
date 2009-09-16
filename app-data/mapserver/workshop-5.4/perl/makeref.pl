#!/usr/bin/perl

use mapscript;
use XBase;

$county = 'Itasca';

$map = new mapObj(undef);

$layer = new layerObj($map);
$class = new classObj($layer);

$map->{width} = $map->{height} = 120;

# find the county
$shapefile = new shapefileObj("../data/ctybdpy2", -1) or die ('Unable to open county shapefile');
$table = new XBase "../data/ctybdpy2.dbf" or die XBase->errstr;
$shape = new shapeObj($mapscript::MS_POLYGON);

$i = 0;
$cursor = $table->prepare_select("CTY_NAME") or die XBase->errstr;
while (($name) = $cursor->fetch) {
  last if $name eq $county;
  $i++;
}

$shapefile->get($i, $shape);
$map->{extent} = $shape->{bounds};

# set up the layer
$layer->{name} = 'county';
$layer->{type} = $mapscript::MS_POLYGON;

# set up the class
$class->{color} = $map->addColor(225,225,185);
$class->{outlinecolor} = $map->addColor(128,128,128);

# draw the shape
$img = $map->prepareImage();
$shape->draw($map, $layer, $img, undef, undef);

# save the image
mapscript::msSaveImage($img, '../graphics/reference.gif', 1, 1);
mapscript::msFreeImage($img);

print "Use ". join(' ', ($map->{extent}->{minx}, $map->{extent}->{miny}, $map->{extent}->{maxx}, $map->{extent}->{maxy})) ." for reference extent.\n";
