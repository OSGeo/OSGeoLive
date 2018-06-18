#!/bin/sh
#############################################################################
#
# Purpose: This script will pop-up welcome message when the user logs in.
#
#############################################################################
# Copyright (c) 2018 Open Source Geospatial Foundation (OSGeo)
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

#
# You need a *.desktop launcher (same as for the desktop icons)
# and put it in /home/user/.config/autostart/.


AWAKE=`uptime | sed -e 's/.* up //' -e 's/,.*//' | grep 'min' | cut -f1 -d' '`

if [ -z "$AWAKE" ] || [ "$AWAKE" -gt 10 ] ; then
   # only show when the machine is first switched on
   exit
fi

gxmessage -file /usr/local/share/osgeo-desktop/welcome_message.txt \
   -title "Welcome" -center

