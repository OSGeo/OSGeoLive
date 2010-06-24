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
