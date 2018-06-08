#!/bin/sh
#
# Script to start ipython notebook on a custom port
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

# install_nbextension.sh

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

export LD_LIBRARY_PATH=/usr/lib/grass74/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/usr/lib/grass74/etc/python:$PYTHONPATH
export GISBASE=/usr/lib/grass74/
export PATH=/usr/lib/grass74/bin/:$GISBASE/bin:$GISBASE/scripts:$PATH

export GIS_LOCK=$$

#mkdir -p /home/$USER/Envs/grass7data
mkdir -p $USER_HOME/.grass7
export GISRC=$USER_HOME/.grass7/rc

export GISDBASE=/home/user/grassdata/

export GRASS_TRANSPARENT=TRUE
export GRASS_TRUECOLOR=TRUE
export GRASS_PNG_COMPRESSION=9
export GRASS_PNG_AUTO_WRITE=TRUE

# export OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference

jupyter-notebook --port=8883 --notebook-dir="$USER_HOME/jupyter/notebooks" --ip='*'

