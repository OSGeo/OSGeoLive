#!/bin/sh
# Copyright (c) 2009-2018 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

###########################################
# Variables depending on the installation #
###########################################

# Java home
#select JRE
if [ -d "/usr/lib/jvm/java-7-openjdk-i386" ]; then
        echo "OpenJDK 7 (i386) found"
        export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-i386"
elif [ -d "/usr/lib/jvm/java-7-openjdk" ]; then
        echo "OpenJDK 7 found"
        export JAVA_HOME="/usr/lib/jvm/java-7-openjdk"
elif [ -d "/usr/lib/jvm/java-6-openjdk" ]; then
        echo "OpenJDK 6 found"
        export JAVA_HOME="/usr/lib/jvm/java-6-openjdk"
elif [ -d "/usr/lib/jvm/java-6-sun" ]; then
        echo "Sun JRE found"
        export JAVA_HOME="/usr/lib/jvm/java-6-sun"
else
        echo "JRE not found, using default"
fi

# gvSIG installation folder
GVSIG_HOME='/opt/gvSIG_1.12'


# gdal data files
# Don't need to set it, as it is defined by default by the linux or mac packages
#export GDAL_DATA="/usr/share/gdal15/"

###################################################################
# Variables not depending (at least directly) on the installation #
###################################################################

# gvSIG native libraries location 
#GVSIG_NATIVE_DEPMAN_LIBS="${HOME}/.depman/lib"
#GVSIG_NATIVE_BINARIES_LIBS="/home/cordin/projects/gvsig/svn/gvSIG-2.0/binaries/linux/"
#GVSIG_NATIVE_LIBS="${GVSIG_NATIVE_DEPMAN_LIBS}:${GVSIG_NATIVE_BINARIES_LIBS}"
GVSIG_NATIVE_LIBS=${GVSIG_HOME}/native:${HOME}/.depman/lib

# Proj4 data files
export PROJ_LIB="${GVSIG_HOME}/gvSIG/extensiones/org.gvsig.crs/data"

# GDAL data files
export GDAL_DATA="${GVSIG_HOME}/data/gdal"

# Native libraries path
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GVSIG_NATIVE_LIBS"

# Go into the gvSIG installation folder, just in case
cd "${GVSIG_HOME}"

# Load gvSIG Andami jars and dependencies for the classpath 
for i in ./lib/*.jar ; do
  LIBRARIES=$LIBRARIES:"$i"
done
for i in ./lib/*.zip ; do
  LIBRARIES=$LIBRARIES:"$i"
done
LIBRARIES=$LIBRARIES:andami.jar

# echo Initial libraries found: ${LIBRARIES}

# gvSIG Andami launcher
GVSIG_LAUNCHER=org.gvsig.andamiupdater.Updater

# gvSIG initial classpath
GVSIG_CLASSPATH=$LIBRARIES

########################
# Memory configuration #
########################

# Initial gvSIG memory (M=Megabytes, G=Gigabytes)
GVSIG_INITIAL_MEM=128M
# Maximum gvSIG memory (M=Megabytes, G=Gigabytes)
GVSIG_MAX_MEM=512M
# Maximum permanent memory size: needed to load classes and statics
GVSIG_MAX_PERM_SIZE=96M

################
# Launch gvSIG #
################

# Temporary fix for number locale related formatting error with proj4.
export LC_NUMERIC=C

# For Java parameters documentation and more parameters look at:
# http://download.oracle.com/javase/6/docs/technotes/tools/windows/java.html
# http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html

if [ -f /home/$USER/gvSIG/sample-project.gvp ]; then
  echo Launching gvSIG: ${JAVA_HOME}/bin/java \
    -Djava.library.path=/usr/lib:"${GVSIG_NATIVE_LIBS}" \
    -cp $GVSIG_CLASSPATH \
    -Xms${GVSIG_INITIAL_MEM} \
    -Xmx${GVSIG_MAX_MEM} \
    -XX:MaxPermSize=${GVSIG_MAX_PERM_SIZE} \
    $GVSIG_LAUNCHER gvSIG gvSIG/extensiones "/home/$USER/gvSIG/sample-project.gvp"

  ${JAVA_HOME}/bin/java \
    -Djava.library.path=/usr/lib:"${GVSIG_NATIVE_LIBS}" \
    -cp $GVSIG_CLASSPATH \
    -Xms${GVSIG_INITIAL_MEM} \
    -Xmx${GVSIG_MAX_MEM} \
    -XX:MaxPermSize=${GVSIG_MAX_PERM_SIZE} \
    $GVSIG_LAUNCHER gvSIG gvSIG/extensiones "/home/$USER/gvSIG/sample-project.gvp"
else
  echo Launching gvSIG: ${JAVA_HOME}/bin/java \
    -Djava.library.path=/usr/lib:"${GVSIG_NATIVE_LIBS}" \
    -cp $GVSIG_CLASSPATH \
    -Xms${GVSIG_INITIAL_MEM} \
    -Xmx${GVSIG_MAX_MEM} \
    -XX:MaxPermSize=${GVSIG_MAX_PERM_SIZE} \
    $GVSIG_LAUNCHER gvSIG gvSIG/extensiones "$@"

  ${JAVA_HOME}/bin/java \
    -Djava.library.path=/usr/lib:"${GVSIG_NATIVE_LIBS}" \
    -cp $GVSIG_CLASSPATH \
    -Xms${GVSIG_INITIAL_MEM} \
    -Xmx${GVSIG_MAX_MEM} \
    -XX:MaxPermSize=${GVSIG_MAX_PERM_SIZE} \
    $GVSIG_LAUNCHER gvSIG gvSIG/extensiones "$@"
fi
