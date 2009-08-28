#!/bin/sh

JAVA_OPTS=-Xmx256M
MAIN=com.vividsolutions.jump.workbench.JUMPWorkbench
SAXDRIVER=org.apache.xerces.parsers.SAXParser
if(test -z $JAVA_HOME) then
  JAVA=`which java`
else
  JAVA=$JAVA_HOME/bin/java
fi
if(test -L $0) then
    	auxlink=`ls -l $0 | sed 's/^[^>]*-> //g'`
    	JUMP_HOME=`dirname $auxlink`/..
else 
    	JUMP_HOME=`dirname $0`/..
fi
JUMP_PROPERTIES=$HOME/.jump/workbench-properties.xml
JUMP_DEFAULTP=$JUMP_HOME/bin/default-plugins.xml
JUMP_STATE=$HOME/.jump/

JUMP_PROFILE=~/.jump/openjump.profile
if [ -f "$JUMP_PROFILE" ]; then
  source $JUMP_PROFILE
fi

if [ -z "$JUMP_LIB" ]; then
  JUMP_LIB=$JUMP_HOME/lib
fi

if [ -z "$JUMP_PLUGIN_DIR" ]; then
  JUMP_PLUGIN_DIR=${JUMP_PLUGIN_DIR:=$JUMP_LIB/ext}
fi

if [ -z "$JUMP_PROPERTIES" -o ! -f $JUMP_PROPERTIES ]; then
  JUMP_PROPERTIES=$HOME/.jump/workbench-properties.xml
fi

if [ -z "$JUMP_DEFAULTP" -o ! -f $JUMP_DEFAULTP ]; then
  JUMP_DEFAULTP=$JUMP_HOME/bin/default-plugins.xml
fi

if [ -z "$JUMP_DEFAULTP" -o ! -f $JUMP_DEFAULTP ]; then
  JUMP_DEFAULTP=$JUMP_HOME/scripts/default-plugins.xml
fi

for libfile in $JUMP_LIB/*.jar $JUMP_LIB/*.zip
do
  CLASSPATH=$libfile:$CLASSPATH;
done
CLASSPATH=$JUMP_HOME:$JUMP_HOME/conf:$CLASSPATH
export CLASSPATH;

JUMP_OPTS="-plug-in-directory $JUMP_PLUGIN_DIR"
if [ -f "$JUMP_PROPERTIES" ]; then
  JUMP_OPTS="$JUMP_OPTS -properties $JUMP_PROPERTIES"
fi

if [ -f "$JUMP_DEFAULTP" ]; then
  JUMP_OPTS="$JUMP_OPTS -default-plugins $JUMP_DEFAULTP"
fi

if ( test -d "$JUMP_STATE" || test -f "$JUMP_STATE") then
  JUMP_OPTS="$JUMP_OPTS -state $JUMP_STATE"
fi
JAVA_OPTS="$JAVA_OPTS -Djump.home=$JUMP_HOME"
JAVA_OPTS="$JAVA_OPTS -Dorg.xml.sax.driver=$SAXDRIVER"
JAVA_OPTS="$JAVA_OPTS -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel"

$JAVA -cp $CLASSPATH:$JUMP_HOME/bin $JAVA_OPTS $MAIN $JUMP_OPTS $*
