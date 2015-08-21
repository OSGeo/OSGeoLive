#!/bin/sh
#############################################################################
#
# Purpose: This script will install Jave JRE and Java JDK
#
#############################################################################
# Copyright (c) 2009-2015 Open Source Geospatial Foundation (OSGeo)
#
# Licensed under the GNU LGPL.
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
#############################################################################

if [ "$#" -lt 1 ] || [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: install_java.sh ARCH(i386 or amd64)"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: install_java.sh ARCH(i386 or amd64)"
    exit 1
fi
ARCH="$1"

./diskspace_probe.sh "`basename $0`" begin
####


#apt-get install --yes default-jdk default-jre
apt-get install --yes openjdk-7-jdk openjdk-7-jre default-jre

apt-get --assume-yes install gsfonts-x11 ttf-dejavu-extra

# Detect build architecture for JAVA_HOME default
if [ "$ARCH" = "i386" ] ; then
    ln -s /usr/lib/jvm/java-7-openjdk-i386 /usr/lib/jvm/default-java
fi

if [ "$ARCH" = "amd64" ] ; then
    ln -s /usr/lib/jvm/java-7-openjdk-amd64 /usr/lib/jvm/default-java
fi

# in case of emergency break glass:
#cat << EOF > /etc/profile.d/set_JAVA_HOME.sh
#JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386
#export JAVA_HOME
#EOF

### see if we can reinstall this without bringing in the kitchen sink
###   otherwise we'll drop it
#apt-get --assume-yes install pdftk


####
./diskspace_probe.sh "`basename $0`" end
