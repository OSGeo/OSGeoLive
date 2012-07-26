#!/bin/sh
#########################
##
## deegree stop script
## author: Judit Mays
##
#########################

## stop tomcat (and deegree webapps):
## kill the deegree-tomcat process
DEE_DIR="/usr/local/lib/deegree-webservices-3.2-pre9"

## stop tomcat (and deegree webapps)
cd $DEE_DIR
./bin/catalina.sh stop