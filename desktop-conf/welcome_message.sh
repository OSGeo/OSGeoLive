#!/bin/sh

# Welcome pop-up message when the user logs in.
#
# You need a *.desktop launcher (same as for the desktop icons)
# and put it in /home/user/.config/autostart/.
#  Exec=gxmessage -file /home/user/welcome.txt 
#    or
#  Exec=/path/to/this/script.sh
#
# and maybe more?

echo"
Welcome to the OSGeo-Live GIS DVD.
Have a nice time. There's beer in the fridge.
" | gxmessage -file - -title "Welcome to the OSGeo Live GIS Disc"

