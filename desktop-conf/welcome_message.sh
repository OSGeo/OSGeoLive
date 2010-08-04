#!/bin/sh

# Welcome pop-up message when the user logs in.
#
# You need a *.desktop launcher (same as for the desktop icons)
# and put it in /home/user/.config/autostart/.


AWAKE=`uptime | sed -e 's/.* up //' -e 's/,.*//' | grep 'min' | cut -f1 -d' '`

if [ -z "$AWAKE" ] || [ "$AWAKE" -gt 10 ] ; then
   # only show when the machine is first switched on
   exit
fi

gxmessage -file /usr/local/share/osgeo-desktop/welcome_message.txt \
   -title "Welcome" -center

