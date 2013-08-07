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

# About:
# =====
# This script will install ipython and ipython-notebook in ubuntu
# The future may hold interesting graphical examples using notebook + tools

./diskspace_probe.sh "`basename $0`" begin
####

echo "deb http://archive.ubuntu.com/ubuntu precise-backports main restricted universe" \
      | sudo tee /etc/apt/sources.list.d/backports.list

apt-get update

apt-get install --assume-yes ipython-notebook -t precise-backports

sudo rm -f /etc/apt/sources.list.d/backports.list

apt-get update

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi



##### Setup custom IPython profile
## doesn't work!  sudo -u "$USER_NAME" \

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"



DATA_URL="http://download.osgeo.org/livedvd/data/ossim/"
QUICKSTART=/usr/local/share/ossim/quickstart

wget --progress=dot:mega "$DATA_URL/ipython-notebook.desktop" \
     --output-document="$QUICKSTART"/workspace/ipython-notebook.desktop

#pip install --upgrade ipython
pip install http://archive.ipython.org/testing/1.0.0/ipython-1.0.0a1.zip

ipython profile create osgeolive
mkdir -p "$USER_HOME"/.config/
mv ~/.ipython "$USER_HOME"/.config/ipython
sed -i -e "s|root|$USER_NAME|" "$USER_HOME"/.config/ipython/profile_osgeolive/*.py

mkdir -p /etc/skel/.config
cp -r "$USER_HOME"/.config/ipython /etc/skel/.config

IPY_CONF="$USER_HOME/.config/ipython/profile_osgeolive/ipython_notebook_config.py"
cat << EOF >> "$IPY_CONF"
c.NotebookApp.open_browser = False
c.NotebookApp.port = 12345
c.NotebookManager.save_script=True
c.FileNotebookManager.notebook_dir = u'/usr/local/share/ossim/quickstart/workspace'
EOF

cp "$IPY_CONF" /etc/skel/.config/ipython/profile_osgeolive/
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"/.config


####
./diskspace_probe.sh "`basename $0`" end
