#!/bin/sh
#
# Script to start ipython notebook on a custom port
#

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


## 10jun17
##  TODO: review for new GRASS setup on live11
##--------------------------------------------------------------
#export LD_LIBRARY_PATH=/usr/lib/grass72/lib:$LD_LIBRARY_PATH
#export PYTHONPATH=/usr/lib/grass72/etc/python:$PYTHONPATH
#export GISBASE=/usr/lib/grass72/
#export PATH=/usr/lib/grass72/bin/:$GISBASE/bin:$GISBASE/scripts:$PATH

#export GIS_LOCK=$$

#mkdir -p /home/$USER/Envs/grass7data
#mkdir -p $USER_HOME/.grass7
#export GISRC=$USER_HOME/.grass7/rc

#export GISDBASE=/home/user/grassdata/

#export GRASS_TRANSPARENT=TRUE
#export GRASS_TRUECOLOR=TRUE
#export GRASS_PNG_COMPRESSION=9
#export GRASS_PNG_AUTO_WRITE=TRUE

#export OSSIM_PREFS_FILE=/usr/share/ossim/ossim_preference
#------------------------------------------------------------


jupyter notebook --port=8883 --no-browser \
   --notebook-dir="$USER_HOME/jupyter/notebooks" \
   --ip='*'

