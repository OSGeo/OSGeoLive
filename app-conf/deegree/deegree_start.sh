#!/bin/sh
#########################
##
## deegree start script
## for OSGeoLiveDVD 2011
##
## author: Judit Mays, Johannes Kuepper
##
#########################

DEE_DIR="/usr/local/lib/deegree-webservices-3.2-pre9"

## stop system's tomcat (port 8080 conflict)
#echo "user" | sudo -S /etc/init.d/tomcat6 stop
#sleep 2

## start tomcat (and deegree webapps)
sudo bash -c "$DEE_DIR/bin/catalina.sh run" &

## sleep for 5 sec, due to the tomcat hasn't started yet
sleep 5

## open firefox with deegree 3 console
## open as user "user" to avoid problems with already running instances of firefox
sudo -u user firefox -new-tab http://localhost:8033/deegree-webservices

