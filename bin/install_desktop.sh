#!/bin/sh
#############################################################################
#
# Purpose: This script will install a desktop background image, password file,
# taskbar,and generally clean up the user desktop-interface experience.
# The menu creation and icon sorting has moved to install_icons_and_menus.sh
#
#############################################################################
# Copyright (c) 2009-2022 Open Source Geospatial Foundation (OSGeo) and others.
#
# Licensed under the GNU LGPL.
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
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


# Default password list on the desktop to be replaced by html help in the future.
cp ../desktop-conf/passwords.txt "$USER_HOME/Desktop/"
chown "$USER_NAME"."$USER_NAME" "$USER_HOME/Desktop/passwords.txt"

# Setup the default desktop background image
cp ../desktop-conf/osgeo-desktop.png \
    /usr/share/lubuntu/wallpapers/

cp ../desktop-conf/osgeo-desktop-transparent.png \
   /usr/share/lubuntu/wallpapers/

### Set the desktop background
sed -i -e 's|^DesktopShortcuts=.*|DesktopShortcuts=Home, Trash|' \
       -e 's|^WallpaperMode=.*|WallpaperMode=fit|' \
       -e 's|^Wallpaper=.*|Wallpaper=/usr/share/lubuntu/wallpapers/osgeo-desktop.png|' \
       -e 's|^BgColor=.*|BgColor=#000000|' \
       -e 's|^FgColor=.*|FgColor=#ffffff|' \
       -e 's|^UseTrash=.*|UseTrash=true|' \
   /etc/xdg/xdg-Lubuntu/pcmanfm-qt/lxqt/settings.conf

## Dark Desktop shadow configuration ^^
##        -e 's|^FgColor=.*|FgColor=#ffffff|' \

## Bright Desktop shadow configuration ^^
##        -e 's|^FgColor=.*|FgColor=#232323|' \
##        -e 's|^ShadowColor=.*|ShadowColor=#A09A8F|' \

## OSGeo font colors
##       -e 's|^FgColor=.*|FgColor=#4db05b|' \
##       -e 's|^ShadowColor=.*|ShadowColor=#003842|' \

## Removed this for xenial: -e 's|^desktop_shadow=.*|desktop_shadow=.*\nshow_mounts=1|' \

# echo "desktop_folder_new_win=1" >> /etc/xdg/pcmanfm/lubuntu/pcmanfm.conf

# New way to set login screen background as of 20.04 that uses sddm instead of lightdm
sed -i -e 's|^background=.*|background=/usr/share/lubuntu/wallpapers/osgeo-desktop-transparent.png|' \
   /usr/share/sddm/themes/lubuntu/theme.conf

# Set the installer desktop icon to OSGeoLive
sed -i -e 's|Lubuntu|OSGeoLive|' \
       -e 's|22.04 LTS|15.0rc1|' \
   /usr/share/applications/lubuntu-calamares.desktop

#Add the launchhelp script which allows other apps to provide sudo
#    launching with the password already embedded
#[Geonetwork and] deegree need this right now
mkdir -p "$USER_HOME/bin/"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/bin/"
mkdir -p /etc/skel/bin

cp "launchassist.sh" "$USER_HOME/bin/"
chmod 700 "$USER_HOME/bin/launchassist.sh"
chown "$USER_NAME.$USER_NAME" \
   "$USER_HOME/bin/launchassist.sh" "$USER_HOME/bin"
# no good to copy it to /etc/skel as the pw will differ for each account
#cp "launchassist.sh" /etc/skel/bin/
#chmod 700 "/etc/skel/bin/launchassist.sh"

##### Setup Automatic or Timed Login #####
# echo "TODO: update autologin preferences for lightdm."
#cp "$BUILD_DIR"/../desktop-conf/custom.conf /etc/gdm/custom.conf


##### Setup timed welcome message
apt-get --assume-yes install gxmessage

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

cat << EOF > "/usr/local/share/osgeo-desktop/desktop-truster.desktop"
[Desktop Entry]
Name=Desktop Truster
Comment=Autostarter to trust all desktop files
Exec=/usr/local/share/osgeo-desktop/desktop-truster.sh
Type=Application
EOF

cat << EOF > "/usr/local/share/osgeo-desktop/apache-fixer.desktop"
[Desktop Entry]
Name=Apache Fixer
Comment=Autostarter to fix apache issue on boot
Exec=/usr/local/share/osgeo-desktop/apache-fixer.sh
Type=Application
EOF

mkdir -p "$USER_HOME"/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   "$USER_HOME"/.config/autostart/
cp /usr/local/share/osgeo-desktop/desktop-truster.desktop \
   "$USER_HOME"/.config/autostart/
cp /usr/local/share/osgeo-desktop/apache-fixer.desktop \
   "$USER_HOME"/.config/autostart/
mkdir -p /etc/skel/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   /etc/skel/.config/autostart/
cp /usr/local/share/osgeo-desktop/desktop-truster.desktop \
   /etc/skel/.config/autostart/
cp /usr/local/share/osgeo-desktop/apache-fixer.desktop \
   /etc/skel/.config/autostart/

cp "$BUILD_DIR/../desktop-conf/welcome_message.sh" \
   /usr/local/share/osgeo-desktop/
cp "$BUILD_DIR/../desktop-conf/desktop-truster.sh" \
   /usr/local/share/osgeo-desktop/
cp "$BUILD_DIR/../desktop-conf/apache-fixer.sh" \
   /usr/local/share/osgeo-desktop/

#
# LANG_CODE is defined in main.sh
#
#cp "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.* \
#   /usr/local/share/osgeo-desktop/

if [ -e "$BUILD_DIR/../desktop-conf/$LANG_CODE"/welcome_message.txt ] ; then
  cp "$BUILD_DIR/../desktop-conf/$LANG_CODE"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
else
  cp "$BUILD_DIR/../desktop-conf"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
fi

cp /usr/local/share/osgeo-desktop/welcome_message.txt "$USER_HOME"/
chown "$USER_NAME"."$USER_NAME" "$USER_HOME"/welcome_message.txt
cp /usr/local/share/osgeo-desktop/welcome_message.txt /etc/skel/


# xdg nm-applet not loading by default, re-add it to user autostart
# cp /etc/xdg/autostart/nm-applet.desktop  /etc/skel/.config/autostart/

#alternate: have it launch a script in /usr/local/restart_dns.sh
# if [ `ifconfig -s | grep -cw ^eth0` -eq 1 ] ; then
#   dhclient eth0   # sudo needed?
# fi

# cat << EOF > "/etc/skel/.config/autostart/force_dns.desktop"
# [Desktop Entry]
# Type=Application
# Encoding=UTF-8
# Name=Manually trigger DNS setting from DHCP
# Comment=Work around for missing resolv.conf bug
# Exec=sudo --non-interactive dhclient eth0
# Terminal=false
# StartupNotify=false
# Hidden=false
# EOF

# Tweak (non-default) theme so that window borders are wider so easier to grab.
sed -i -e 's|^border.width: 1|border.width: 2|' \
   /usr/share/themes/Mikachu/openbox-3/themerc


# Long live the classic X11 keybindings
cat << EOF > /etc/skel/.xinitrc
setxkbmap -option keypad:pointerkeys
setxkbmap -option terminate:ctrl_alt_bksp
EOF


# work around for launchpad bug #975152 (opens empty lxterminal; trac #1363)
#   and make the icons not so huge
# sed -i -e 's|lxsession-default-terminal %s|x-terminal-emulator -e %s|' \
#        -e 's|big_icon_size=48|big_icon_size=36|' \
#    /etc/xdg/lubuntu/libfm/libfm.conf

# sed -i -e 's|lxsession-default terminal|x-terminal-emulator|' \
#    /usr/share/lxpanel/profile/Lubuntu/config


# add some file types to the master mime.types file
#  ("users can create their own by creating a .mime.types
#   files in their home directory")

# set default TIFF viewer to QGIS
sed -i -e 's|^image/tiff=.*|image/tiff=qgis.desktop|' \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

# associate shapefiles and .qgs with QGIS
echo "application/x-qgis=qgis.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

echo >> /etc/mime.types
echo "application/x-sqlite3\t\t\t\tsqlite" >> \
   /etc/mime.types
echo "application/x-sqlite3=spatialite-gui.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

echo "application/x-openstreetmap+xml\t\t\tosm osc" >> \
   /etc/mime.types
echo "application/x-openstreetmap+xml=josm.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

# mmph, should be a drag-and-drop viewer
echo "application/x-netcdf=ncWMS-start.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

# jupyter notebooks
echo "application/x-ipynb+json\t\t\tipynb" >> \
   /etc/mime.types
# erhm..
echo "application/x-ipynb+json=osgeo-jupyter-notebook.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

echo "application/x-mbtiles+sql\t\t\tmbtiles" >> \
   /etc/mime.types
echo "application/x-mbtiles+sql=qgis.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

echo "application/gpx+xml\t\t\t\tgpx" >> \
   /etc/mime.types
echo "application/gpx+xml=gpsprune.desktop" >> \
   /etc/xdg/xdg-Lubuntu/mimeapps.list

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
