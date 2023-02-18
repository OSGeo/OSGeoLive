#!/bin/sh
# Copyright (c) 2018-2023 The Open Source Geospatial Foundation and others.
# Licensed under the GNU LGPL v.2.1.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install PDAL -
#    osgeolive 12dev  -dbb
#    PDAL homepage: https://pdal.io
#

./diskspace_probe.sh "`basename $0`" begin
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

PACKAGES="pdal libpdal-util13 libpdal-base13"
PDAL_PLUGINS="libpdal-plugins"

# pkg not installed to save disc space:
#   pdal-doc

apt-get --assume-yes install ${PACKAGES}
 # ${PDAL_PLUGINS}

if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi

# install data for PDAL
#echo "2" | sudo gmt-coastline-download

#echo 'export PATH="$PATH:/usr/lib/PDAL/bin"' > /etc/profile.d/PDAL_path.sh
#cat << EOF > /etc/profile.d/PDAL_path.sh
#PATH="\$PATH:/usr/lib/pdal/bin"
#export PATH
#EOF

####
./diskspace_probe.sh "`basename $0`" end
