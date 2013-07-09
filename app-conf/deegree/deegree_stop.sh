#!/bin/sh
#########################
##
## deegree stop script
## for OSGeoLiveDVD 2011
##
## author: Johannes Wilden
##
## Credits: Judit Mays, Johannes Kuepper 
#########################

## stop tomcat (and deegree webapps):
## kill the deegree-tomcat process
DEE_DIR="/usr/local/lib/deegree-webservices-3.3.1"

## stop tomcat (and deegree webapps)
cd $DEE_DIR
./bin/catalina.sh stop