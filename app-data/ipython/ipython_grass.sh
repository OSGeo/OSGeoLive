#!/bin/sh
#
# Script to start minimal GRASS session for ipython
#

# Conditionally add $LD_LIBRARY_PATH and $PYTHONPATH only if they already exist.
# An empty ":" at the end can add `pwd` to the path, which is generally frowned upon.
if [ -n "$LD_LIBRARY_PATH" ] ; then
   LD_LIBRARY_PATH="/usr/lib/grass64/lib:$LD_LIBRARY_PATH"
else
   LD_LIBRARY_PATH="/usr/lib/grass64/lib"
fi

if [ -n "$PYTHONPATH" ] ; then
   PYTHONPATH="/usr/lib/grass64/etc/python:$PYTHONPATH"
else
   PYTHONPATH="/usr/lib/grass64/etc/python"
fi

GISBASE="/usr/lib/grass64"
PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
GIS_LOCK="$$"
GISRC="/home/$USER/.grassrc6"
export LD_LIBRARY_PATH PYTHONPATH GISBASE PATH GIS_LOCK GISRC

# note: $GISDBASE is generally a g.gisenv variable stored in .grassrc6, not a shell variable anymore
GISDBASE="/home/$USER/grassdata"
export GISDBASE

GRASS_TRANSPARENT=TRUE
GRASS_TRUECOLOR=TRUE
GRASS_PNG_COMPRESSION=9
GRASS_PNG_AUTO_WRITE=TRUE
export GRASS_TRANSPARENT GRASS_TRUECOLOR GRASS_PNG_COMPRESSION GRASS_PNG_AUTO_WRITE

mkdir -p /home/user/ossim/workspace

ipython notebook --port=12345 --no-browser \
   --notebook-dir=/home/user/ipython/IPython_notebooks \
   --ip='*'

