#!/bin/sh
JAVA_HOME="/usr/lib/jvm/default-java"

dir=`dirname $0`
cd $dir

cd ../jetty
rm logs/*request.log*
rm logs/output.log
mv logs/geonetwork.log.* logs/archive
mv logs/geoserver.log.* logs/archive

export JETTY_HOME=.
 
${JAVA_HOME}/bin/java -Xms512m -Xmx1024m -Xss2M -XX:MaxPermSize=128m -DSTOP.PORT=8879 -Djeeves.filecharsetdetectandconvert=enabled -Dmime-mappings=../web/geonetwork/WEB-INF/mime-types.properties -Djava.awt.headless=true -DSTOP.KEY=geonetwork -jar start.jar > logs/output.log 2>&1 &

(sleep 15; echo "25"; sleep 15; echo "50"; sleep 15; echo "75"; sleep 15; echo "100") | zenity --progress --auto-close --text "GeoNetwork starting"

firefox http://localhost:8880/geonetwork/
