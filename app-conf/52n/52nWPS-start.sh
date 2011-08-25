#!/bin/bash


/usr/local/52nWPS/tomcat_start.sh restart

DELAY=30

(
for TIME in `seq $DELAY` ; do
  sleep 1
  echo "$TIME $DELAY" | awk '{print int(0.5+100*$1/$2)}'
done
) | zenity --progress --auto-close --text "52North WPS starting"

# how to set 5 sec timeout?
zenity --info --text "Starting web browser ..."

firefox "http://localhost:8083/wps/test.html"
