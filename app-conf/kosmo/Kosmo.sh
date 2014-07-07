#!/bin/sh
# Kosmo.sh

cd /usr/lib/Kosmo-3.1/bin

KOSMO_LIBS_PATH="../native"
GDAL_LIBS_PATH="../native"
PROJ_LIB="./crs/data"
export PROJ_LIB

if [ -n "$LD_LIBRARY_PATH" ] ; then
    LD_LIBRARY_PATH="$KOSMO_LIBS_PATH:$LD_LIBRARY_PATH"
else
    LD_LIBRARY_PATH="$KOSMO_LIBS_PATH"
fi
export LD_LIBRARY_PATH

if [ -n "$GDAL_DRIVER_PATH" ]; then
	GDAL_DRIVER_PATH=$GDAL_LIBS_PATH:$GDAL_DRIVER_PATH
else
	GDAL_DRIVER_PATH=$GDAL_LIBS_PATH
fi
export GDAL_DRIVER_PATH

java -Djava.library.path=/usr/lib:"../native" \
     -Dsun.java2d.d3d=false \
     -cp .:./kosmo-desktop-core-3.1.jar:./ext/libs/*:./ext/* \
     -Xmx800M "com.vividsolutions.jump.workbench.JUMPWorkbench" \
     -plug-in-directory "./ext"

