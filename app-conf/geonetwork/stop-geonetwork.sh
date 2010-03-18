#!/bin/sh
JAVA_HOME="/usr/lib/jvm/java-6-sun"
dir=`dirname $0`
cd $dir

cd ../jetty
${JAVA_HOME}/bin/java -DSTOP.PORT=8879 -DSTOP.KEY=geonetwork -jar start.jar --stop
