#!/bin/sh
#########################
##
## deegree start script
## for OSGeo LiveDVD
##
## Date:    $Date: $
## Revision:$Revision: $
##
#########################

## set JAVA_HOME

if(test -z $JAVA_HOME) then
  javaversion="noJava"
else
  javaversion=$($JAVA_HOME/bin/java -version 2>&1 |head -1 |awk 'BEGIN{FS="\""}{print $2}'|awk 'BEGIN{FS="_"}{print $1}')
fi

## use Java5 if available, otherwise use Java6 
if(test -z "$JAVA_HOME" -o $javaversion = 1.6.0 -o $javaversion = 1.4.2) then
  for file in /usr/lib/jvm/*java*6*sun* /usr/lib/jvm/*java*5*sun*
  do 
    if(test -x $file/bin/java) then
      export JAVA_HOME=$file
    fi
  done
fi

##
if(test -z $JAVA_HOME) then
  echo "JAVA_HOME could not be set. deegree will not be started."
  return
fi


## set JAVA_OPTS
export JAVA_OPTS="-Xms256m -Xmx512m -XX:MaxPermSize=256m"

mkdir -p /tmp/deegree-logs/ /tmp/deegree-work/

## start tomcat (and deegree webapps)
bash -c "/usr/lib/deegree-2.2_tomcat-6.0.20/bin/catalina.sh start"

## open firefox with index.html 
## open as user "user" to avoid problems with already running instances of firefox
sudo -u user firefox -new-tab http://localhost:8081/ &

