#!/bin/sh
# Copyright (c) 2011 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will install openjdk version 7
#
# for Ubuntu >=11.10 openjdk-7 is in the official archives:
#apt-get install openjdk-7-jre icedtea-plugin ttf-dejavu-extra
#  (icedtea is now to be dropped?)

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
