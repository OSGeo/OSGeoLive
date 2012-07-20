#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# script to install GMT - The Generic Mapping Tools
#    written by H.Bowman <hamish_b  yahoo com>
#    GMT homepage: http://gmt.soest.hawaii.edu/
#


# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


PACKAGES="gmt gmt-doc gmt-coast-low \
   gmt-examples gmt-tutorial gmt-tutorial-pdf gv"

# pkg not installed to save 15mb disc space:
#   gmt-doc-pdf

apt-get --assume-yes install $PACKAGES

if [ $? -ne 0 ] ; then
   echo "ERROR: package install failed."
   exit 1
fi

# install high res world coastline (currently disabled due to disc space concerns)
#echo "2" | sudo gmt-coastline-download


# add GMT apps to the PATH if not already done
if [ `grep -c '/usr/lib/gmt/bin' "$USER_HOME/.bashrc"` -eq 0 ] ; then
   echo 'export PATH="$PATH:/usr/lib/gmt/bin"' >> "$USER_HOME/.bashrc"
fi

echo "Finished installing GMT."

