#!/usr/bin/env bash
export JAVA_HOME="/usr/lib/jvm/default-java"
export JETTY_HOME=../jetty
export JETTY_FOREGROUND=0
export JETTY_BASE=$JETTY_HOME
cd $JETTY_HOME

for i in "$@"
do
case $i in
    -f*)
    JETTY_FOREGROUND=1
    shift
    ;;
    *)
    ;;
esac
done

$JAVA_HOME/bin/java -DSTOP.PORT=8879 -DSTOP.KEY=geonetwork -jar start.jar --stop

zenity --info --text "GeoNetwork stopped"
