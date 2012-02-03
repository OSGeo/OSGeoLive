#!/bin/sh
#########################
##
## deegree stop script
## author: Judit Mays
##
#########################

## stop tomcat (and deegree webapps):
## kill the deegree-tomcat process
pid=$(ps fax|grep deegree|grep java|grep -v grep|cut -d\   -f 2)
kill -9 $pid


## restart system's tomcat (port 8080 conflict??)
#sleep 2
#echo "user" | sudo -S /etc/init.d/tomcat6 start

