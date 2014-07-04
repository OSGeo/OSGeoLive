#!/bin/sh
# Copyright (c) 2013 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install ipython and ipython-notebook in ubuntu
# The future may hold interesting graphical examples using notebook + tools

./diskspace_probe.sh "`basename $0`" begin
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BUILD_DIR=`pwd`

## 24jan14  change in iPython+numpy+matplotlib
## 04jul14  jtaylor iPython

##-- no longer needed ?
#apt-get install --assume-yes libfreetype6-dev libpng12-dev
#apt-get install --assume-yes python-dev python-setuptools

##-- causes a rebuild of numpy, unfortunatly..
apt-get install --assume-yes python-pip
apt-get install --assume-yes python-scipy python-pandas python-netcdf

#-- iPython from jtaylor .deb
apt-add-repository --yes ppa:jtaylor/ipython
apt-get update

apt-get install --assume-yes ipython ipython-notebook ipython-qtconsole

#-- Clean-up
apt-add-repository --yes --remove ppa:jtaylor/ipython
#apt-get remove --assume-yes python-dev
#apt-get remove --assume-yes libfreetype6-dev libpng12-dev

##-------------------------------------------------------
#### Setup OSSIM workspace
#### epifanio - FIXME  04jul14

DATA_URL="http://download.osgeo.org/livedvd/data/ossim/"

mkdir -p /usr/local/share/ossim/quickstart/workspace
QUICKSTART=/usr/local/share/ossim/quickstart

#pip install --upgrade ipython
#pip install http://archive.ipython.org/testing/1.0.0/ipython-1.0.0a1.zip

##### Setup custom IPython profile
# commenting out, the keywords are now in the command line fro ipython_grass.sh


#mkdir -p "$USER_HOME"/.config
#chown "$USER.$USER" "$USER_HOME"/.config

## 'sudo -u "$USER_NAME"' by itself doesn't work, need to overset $HOME as well.
#HOME="$USER_HOME" \
# sudo -u "$USER_NAME" \
# ipython profile create osgeolive

#mkdir -p /etc/skel/.config

# weirdness (see trac bug #1215)
#if [ -d "$USER_HOME"/.config/ipython ] ; then
#   cp -r "$USER_HOME"/.config/ipython /etc/skel/.config
#   IPY_CONF="$USER_HOME/.config/ipython/profile_osgeolive/ipython_notebook_config.py"
#else
#   cp -r "$USER_HOME"/.ipython /etc/skel/.config/ipython
#   IPY_CONF="$USER_HOME/.ipython/profile_osgeolive/ipython_notebook_config.py"
#fi

#cat << EOF >> "$IPY_CONF"
#c.NotebookApp.open_browser = False
#c.NotebookApp.port = 12345
#c.NotebookManager.save_script=True
#c.FileNotebookManager.notebook_dir = u'/usr/local/share/ossim/quickstart/workspace/geo-notebook'
#c.NotebookApp.ip = '*'
#EOF

#cp "$IPY_CONF" /etc/skel/.config/ipython/profile_osgeolive/
#chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/.config

#cp "$BUILD_DIR/../app-data/ossim/ipython_grass.sh" \
#   /usr/local/bin/

#cp "$BUILD_DIR"/../app-data/ossim/ipython-notebook*.desktop \
#   "$QUICKSTART"/workspace/

#TODO:
#cp "$BUILD_DIR"/../app-data/ossim/ipython-notebook*.desktop \
#   "$USER_DESKTOP"/
#chown "$USER_NAME:$USER_NAME" "$USER_DESKTOP"/ipython-notebook*.desktop

# no-op?
#chmod a+x /usr/local/bin/ipython_grass.sh

# probably better to move this to a script in the app-conf/ dir.
#IPY_GRASS="/usr/local/bin/ipython_grass.sh"
#cat << EOF > "$IPY_GRASS"
#!/bin/bash -l
#export LD_LIBRARY_PATH=/usr/lib/grass64/lib:\$LD_LIBRARY_PATH
#export PYTHONPATH=/usr/lib/grass64/etc/python:\$PYTHONPATH
#export GISBASE=/usr/lib/grass64/
#export PATH=/usr/lib/grass64/bin/:\$GISBASE/bin:\$GISBASE/scripts:\$PATH
#export GIS_LOCK=\$$
#export GISRC=/home/\$USER/.grassrc6
#export GISDBASE=/home/\$USER/grassdata
#export GRASS_TRANSPARENT=TRUE
#export GRASS_TRUECOLOR=TRUE
#export GRASS_PNG_COMPRESSION=9
#export GRASS_PNG_AUTO_WRITE=TRUE
#ipython notebook --pylab=inline --profile=osgeolive
#EOF
#chmod a+x "$IPY_GRASS"

#git clone https://github.com/epifanio/geo-notebook \
#  /usr/local/share/ossim/quickstart/workspace/geo-notebook

#rm -rf /usr/local/share/ossim/quickstart/workspace/geo-notebook/.git


####
./diskspace_probe.sh "`basename $0`" end
