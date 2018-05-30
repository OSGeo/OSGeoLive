#!/bin/sh/
#############################################################################
#
# Purpose: Takes script/app to launch as an arg an makes sure it's run as sudo.
# Seems to alleviate strange behavior of desktop icons not launching apps properly
#
#############################################################################
# Copyright (c) 2009-2018 Open Source Geospatial Foundation (OSGeo) and others.
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

PASSWORD=user
echo "Launching $1"
echo $PASSWORD | sudo -S $1
