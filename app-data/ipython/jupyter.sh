#!/bin/bash -l
 
PREFIX=/usr/
 
export LD_LIBRARY_PATH=/usr/lib/grass70/lib:$PREFIX/lib/R/lib/:$LD_LIBRARY_PATH
export PYTHONPATH=/usr/lib/grass70/etc/python:$PYTHONPATH
export GISBASE=/usr/lib/grass70
export PATH=$GISBASE/bin:$GISBASE/scripts:$PATH
 
export GIS_LOCK=$$
 
mkdir -p /home/epilib/Envs/grass7data
mkdir -p /home/epilib/Envs/.grass7
 
export GISRC=/home/user/.grass7/rc
export GISDBASE=/home/user/grassdata
 
export GRASS_TRANSPARENT=TRUE
export GRASS_TRUECOLOR=TRUE
export GRASS_PNG_COMPRESSION=9
export GRASS_PNG_AUTO_WRITE=TRUE
 
GISBASE="/usr/lib/grass70/"
PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
GIS_LOCK="$$"
GISRC="/home/$USER/.grass7/rc"
 
export LD_LIBRARY_PATH PYTHONPATH GISBASE PATH GIS_LOCK GISRC
 
# note: $GISDBASE is generally a g.gisenv variable stored in .grassrc6, not a shell variable anymore
GRASS_RENDER_IMMEDIATE=cairo
GRASS_RENDER_WIDTH=640
GRASS_RENDER_HEIGHT=480
GRASS_RENDER_FILE_READ=TRUE
GRASS_RENDER_TRANSPARENT=TRUE
GRASS_RENDER_TRUECOLOR=TRUE
GRASS_RENDER_PNG_COMPRESSION=9
GRASS_RENDER_PNG_AUTO_WRITE=TRUE
GRASS_RENDER_READ_FILE=TRUE
export GRASS_RENDER_FILE_READ GRASS_RENDER_IMMEDIATE GRASS_RENDER_WIDTH GRASS_RENDER_HEIGHT GRASS_RENDER_TRANSPARENT GRASS_RENDER_TRUECOLOR GRASS_RENDER_PNG_COMPRESSION GRASS_RENDER_PNG_AUTO_WRITE GRASS_RENDER_READ_FILE
 
 
jupyterhub --config=/usr/local/share/jupyter/jupyterhub_config.py --debug