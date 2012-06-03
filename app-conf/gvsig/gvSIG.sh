#!/bin/sh
# gvSIG.sh

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

export GVSIG_LIBS="/opt/gvSIG_1.11/libs/"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GVSIG_LIBS"
export PROJ_LIB="/opt/gvSIG_1.11/bin/gvSIG/extensiones/org.gvsig.crs/data"
export GDAL_DATA="$GVSIG_LIBS/gdal_data"
cd "/opt/gvSIG_1.11/bin"

#copy default symbology
if [ ! -d "$USER_HOME/gvSIG/Styles" ]; then 
    echo "Styles not found"
    cp -r gvSIG/extensiones/org.gvsig.extended-symbology/default_symbology/Styles \
          "$USER_HOME/gvSIG"
fi 
if [ ! -d "$USER_HOME/gvSIG/Symbols" ]; then 
    echo "Symbols not found"
    cp -r gvSIG/extensiones/org.gvsig.extended-symbology/default_symbology/Symbols \
          "$USER_HOME/gvSIG"
fi 


for i in ./lib/*.jar ; do
  LIBRARIES=$LIBRARIES:"$i"
done
for i in ./lib/*.zip ; do
  LIBRARIES=$LIBRARIES:"$i"
done

#select JRE
if [ -d "/usr/lib/jvm/java-6-openjdk" ]; then
        echo "OpenJDK found"
        export PATH="/usr/lib/jvm/java-6-openjdk/bin:$PATH"
elif [ -d "/usr/lib/jvm/java-6-sun" ]; then
        echo "Sun JRE found"
        export PATH="/usr/lib/jvm/java-6-sun/bin:$PATH"
else
        echo "JRE not found, using default"
fi

if [ -e "$USER_HOME/gvSIG/sample-project.gvp" ]; then
	java -Djava.library.path=/usr/lib:"/opt/gvSIG_1.11/libs" \
	     -cp andami.jar$LIBRARIES -Xmx500M com.iver.andami.Launcher \
	     gvSIG gvSIG/extensiones "$USER_HOME/gvSIG/sample-project.gvp" 
else
	java -Djava.library.path=/usr/lib:"/opt/gvSIG_1.11/libs" \
	     -cp andami.jar$LIBRARIES -Xmx500M com.iver.andami.Launcher \
	     gvSIG gvSIG/extensiones "$@"
fi
