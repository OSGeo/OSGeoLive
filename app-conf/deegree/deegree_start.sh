#!/bin/sh
#########################
##
## deegree start script
## for OSGeoLiveDVD 2011
##
## author: Johannes Wilden
##
## Credits: Judit Mays, Johannes Kuepper, Danilo Bretschneider
#########################

export DEEGREE_WORKSPACE_ROOT="/usr/local/share/deegree"
DEE_DIR="/usr/local/lib/deegree-webservices-3.3.10"

## start tomcat (and deegree webapps)
cd $DEE_DIR
mkdir -p logs
./bin/catalina.sh start

## sleep for 5 sec, due to the tomcat hasn't started yet
sleep 5

## open firefox with deegree 3 console
firefox -new-tab http://localhost:8033
