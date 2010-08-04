#!/bin/sh

# Welcome pop-up message when the user logs in.
#
# You need a *.desktop launcher (same as for the desktop icons)
# and put it in /home/user/.config/autostart/.


########################
if [ 1 -eq 0 ] ; then
# move to install_desktop.sh
mkdir -p /usr/local/share/osgeo-desktop

cat << EOF > "/usr/local/share/osgeo-desktop/welcome_message.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Welcome message
Comment=Live Demo welcome message
Exec=/usr/local/share/osgeo-desktop/welcome_message.sh
Terminal=false
StartupNotify=false
Hidden=false
EOF

mkdir -p /home/user/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   /home/user/.config/autostart/
   
# better to put this file in SVN as desktop-conf/welcome_message.txt
#cp ../desktop-conf/welcome_message.* \
#   /usr/local/share/osgeo-desktop/

echo "
Welcome to the OSGeo Live GIS DVD.

Have a nice time. There's beer in the fridge.
" > /usr/local/share/osgeo-desktop/welcome_message.txt

cp /usr/local/share/osgeo-desktop/welcome_message.txt /home/user/
chown user.user /home/user/welcome_message.txt
fi
########################



AWAKE=`uptime | sed -e 's/.* up //' -e 's/,.*//' | grep 'min' | cut -f1 -d' '`

if [ -z "$AWAKE" ] || [ "$AWAKE" -gt 10 ] ; then
   # only show when the machine is first switched on
   exit
fi

gxmessage -file /usr/local/share/osgeo-desktop/welcome_message.txt \
   -title "Welcome"

