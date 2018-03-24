#!/bin/sh
#############################################################################
#
# Purpose: This script will install openjdk version 7
#
#############################################################################
# Copyright (c) 2011-2018 The Open Source Geospatial Foundation and others.
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


apt-get --assume-yes install openjdk-7-jre openjdk-7-jdk \
   openjdk-7-jre-headless ttf-dejavu-extra


# make it easy for developers to switch VMs
if [ `grep -c JAVA_HOME "$USER_HOME/.profile"` -eq 0 ] ; then
   cat << EOF >> "$USER_HOME/.profile"

### Uncomment the following line to use the OpenJDK java VM version 7
#JAVA_HOME=/usr/lib/jvm/java-7-sun; export JAVA_HOME

EOF
fi


####
./diskspace_probe.sh "`basename $0`" end
