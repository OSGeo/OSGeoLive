#!/bin/sh
#
# Script to start Jupyter notebook server on a custom port; Bionic
#
#############################################################################
# Copyright (c) 2010-2018 Open Source Geospatial Foundation (OSGeo)
#
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


if [ -z "$USER_NAME" ] ; then
   USER_NAME=`whoami`
fi
USER_HOME="/home/$USER_NAME"

jupyter notebook --port=8883 --notebook-dir="${USER_HOME}/jupyter/notebook_gallery" --ip='*'

