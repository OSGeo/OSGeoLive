#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL.
# 
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This software is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script will install mysql (put it up front because it has an interactive prompt)

#attempt at setting the root password without the need for interaction
PASSWORD="user"
echo mysql-server-5.0 mysql-server/root_password password $PASSWORD | debconf-set-selections
echo mysql-server-5.0 mysql-server/root_password_again password $PASSWORD | debconf-set-selections

apt-get install --yes mysql-server mysql-admin

