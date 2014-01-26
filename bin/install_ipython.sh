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

## 24jan14  change in iPython+numpy+matplotlib
#echo "deb http://archive.ubuntu.com/ubuntu precise-backports main restricted universe" \
#      | sudo tee /etc/apt/sources.list.d/backports.list

apt-get install --assume-yes libfreetype6-dev libpng12-dev
apt-get install --assume-yes python-dev python-setuptools
## provides easy_install, distribute-0.6.24dev_r0

easy_install --upgrade distribute
## provides
##  /usr/local/lib/python2.7/dist-packages/distribute-0.7.3
##  /usr/local/lib/python2.7/dist-packages/setuptools-2.1

#Xeasy_install -U pip  ## not the right order

apt-get install --assume-yes python-pip python-pandas python-netcdf
## provides pip 1.01

#pip install --upgrade pip ## upgrade pip to 1.5.1

pip install --upgrade numpy
pip install --upgrade pandas
pip install --upgrade matplotlib
## TODO libBlas etc for scipy

#-- iPython from .deb
apt-add-repository --yes ppa:jtaylor/ipython
apt-get update

apt-get install  --assume-yes ipython ipython ipython-notebook ipython-qtconsole

#-- Clean-up
apt-add-repository --yes --remove ppa:jtaylor/ipython
apt-get remove --assume-yes python-dev
apt-get remove --assume-yes libfreetype6-dev libpng12-dev
##-------------------------------------------------------
#### Setup OSSIM workspace

DATA_URL="http://download.osgeo.org/livedvd/data/ossim/"

mkdir -p /usr/local/share/ossim/quickstart/workspace
QUICKSTART=/usr/local/share/ossim/quickstart

wget -nv "$DATA_URL/ipython-notebook.desktop" \
     --output-document="$QUICKSTART"/workspace/ipython-notebook.desktop

#pip install --upgrade ipython
#pip install http://archive.ipython.org/testing/1.0.0/ipython-1.0.0a1.zip

##### Setup custom IPython profile

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

mkdir -p "$USER_HOME"/.config
chown "$USER.$USER" "$USER_HOME"/.config

## 'sudo -u "$USER_NAME"' by itself doesn't work, need to overset $HOME as well.
HOME="$USER_HOME" \
 sudo -u "$USER_NAME" \
 ipython profile create osgeolive

mkdir -p /etc/skel/.config

# weirdness (see trac bug #1215)
if [ -d "$USER_HOME"/.config/ipython ] ; then
   cp -r "$USER_HOME"/.config/ipython /etc/skel/.config
   IPY_CONF="$USER_HOME/.config/ipython/profile_osgeolive/ipython_notebook_config.py"
else
   cp -r "$USER_HOME"/.ipython /etc/skel/.config/ipython
   IPY_CONF="$USER_HOME/.ipython/profile_osgeolive/ipython_notebook_config.py"
fi

cat << EOF >> "$IPY_CONF"
c.NotebookApp.open_browser = False
c.NotebookApp.port = 12345
c.NotebookManager.save_script=True
c.FileNotebookManager.notebook_dir = u'/usr/local/share/ossim/quickstart/workspace/geo-notebook'
EOF

cp "$IPY_CONF" /etc/skel/.config/ipython/profile_osgeolive/
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/.config


# probably better to move this to a script in the app-conf/ dir.
IPY_GRASS="/usr/local/bin/ipython_grass.sh"
cat << EOF > "$IPY_GRASS"
#!/bin/bash -l
export LD_LIBRARY_PATH="/usr/lib/grass64/lib"
if [ -z "$PYTHONPATH" ] ; then
    export PYTHONPATH="/usr/lib/grass64/etc/python"
else
    export PYTHONPATH="/usr/lib/grass64/etc/python:\$PYTHONPATH"
fi
export GISBASE="/usr/lib/grass64"
export PATH="\$PATH:\$GISBASE/bin:\$GISBASE/scripts"
export GIS_LOCK=\$\$
mkdir -p "\$HOME/grassdata"
export GISRC="\$HOME/.grassrc6"
export GISDBASE="/home/\$USER/grassdata"
export GRASS_TRANSPARENT=TRUE
export GRASS_TRUECOLOR=TRUE
export GRASS_PNG_COMPRESSION=9
export GRASS_PNG_AUTO_WRITE=TRUE
cd /usr/local/share/ossim/quickstart/workspace/geo-notebook
ipython notebook --pylab=inline --profile=osgeolive
EOF
chmod a+x "$IPY_GRASS"


git clone https://github.com/epifanio/geo-notebook \
  /usr/local/share/ossim/quickstart/workspace/geo-notebook


####
./diskspace_probe.sh "`basename $0`" end
