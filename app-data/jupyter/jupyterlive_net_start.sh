#!/bin/sh
#
# Script to start ipython notebook on a custom port
#

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

jupyter notebook --port=8883 --no-browser \
   --notebook-dir="$USER_HOME/jupyter/notebooks" \
   --ip='*'

