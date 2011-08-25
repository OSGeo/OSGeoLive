#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will install sun jre 6 and jdk 6

#Next 2 lines make it possible to accept the licence agreement interactively
#Source http://coreyhulen.org/2010/04/11/unattended-java-install-on-linux/
export DEBIAN_FRONTEND=noninteractive
echo "sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true" | debconf-set-selections

add-apt-repository "deb http://archive.canonical.com/ natty partner"
apt-get update

apt-get --assume-yes remove openjdk-6-jre openjdk-6-jre-headless

apt-get --assume-yes install java-common sun-java6-bin \
     sun-java6-jre sun-java6-jdk

apt-get --assume-yes install gsfonts-x11


# this won't work, because the script is not sourced, it's run and so the
#  enviro variable will not propagate back to the partent process.
if [ `grep -c 'JAVA_HOME' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0|JAVA_HOME=/usr/lib/jvm/java-6-sun|' /etc/rc.local
    echo "export JAVA_HOME" >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi
## try it this way instead:
cat << EOF > /etc/profile.d/set_JAVA_HOME.sh
JAVA_HOME=/usr/lib/jvm/java-6-sun
export JAVA_HOME
EOF


### see if we can reinstall this without bringing in the kitchen sink
###   otherwise we'll drop it
#apt-get --assume-yes install pdftk

