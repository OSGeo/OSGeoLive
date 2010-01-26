#!/bin/sh
#########################
##
## deegree stop script
## for OSGeo LiveDVD
##
## Date:    $Date: $
## Revision:$Revision: $
#########################

## stop tomcat (and deegree webapps):
## kill the deegree-tomcat process
pid=$(ps fax|grep deegree|grep java|grep -v grep|cut -d\   -f 2)
kill -9 $pid
