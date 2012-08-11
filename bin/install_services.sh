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
# This script will install ssh and VNC services

echo "==============================================================="
echo "install_services.sh"
echo "==============================================================="

apt-get --assume-yes install openssh-server vnc4server


# For security reasons these must be removed.
#  If you need them, generate fresh ones with:
#    sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
#    sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
#  or more simply
#    sudo dpkg-reconfigure openssh-server
# this is repeated in build_iso.sh, just to be sure.
rm -rf /etc/ssh/ssh_host_[der]*_key*

# check if the ssh keys exist, and if not, run dpkg-reconfigure
#  at boot time to create them
if [ `grep -c 'ssh_host' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local
    echo "if [ ! -e /etc/ssh/ssh_host_rsa_key ] ; then" >> /etc/rc.local
    echo "   dpkg-reconfigure openssh-server" >> /etc/rc.local
    echo "fi" >> /etc/rc.local
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi
