#!/bin/sh
JAVA_HOME="/usr/lib/jvm/java-6-sun"

dir=`dirname $0`
cd $dir

cd ../jetty
rm logs/*request.log*
rm logs/output.log
mv logs/geonetwork.log.* logs/archive
mv logs/intermap.log.*   logs/archive
mv logs/geoserver.log.* logs/archive

# try changing the Xmx parameter if your machine has little RAM
#java -Xms48m -Xmx256m -Xss2M -XX:MaxPermSize=128m -DSTOP.PORT=8079 -Djava.awt.headless=true -DSTOP.KEY=geonetwork -jar start.jar ../bin/jetty.xml &
 
${JAVA_HOME}/bin/java -Xms48m -Xmx512m -Xss2M -XX:MaxPermSize=128m -DSTOP.PORT=8879 -Djava.awt.headless=true -DSTOP.KEY=geonetwork -jar start.jar ../bin/jetty.xml > logs/output.log 2>&1 &

(sleep 10; echo "25"; sleep 10; echo "50"; sleep 10; echo "75"; sleep 10; echo "100") | zenity --progress --auto-close --text "GeoNetwork starting"
