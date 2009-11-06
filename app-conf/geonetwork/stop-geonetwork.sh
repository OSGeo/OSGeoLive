#!/bin/sh

dir=`dirname $0`
cd $dir

cd ../jetty
java -DSTOP.PORT=8879 -DSTOP.KEY=geonetwork -jar start.jar --stop
