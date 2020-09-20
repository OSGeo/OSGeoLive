#!/bin/sh
#############################################################################
#
# Purpose: This script will install a desktop background image, password file,
# taskbar,and generally clean up the user desktop-interface experience.
# The menu creation and icon sorting has moved to install_icons_and_menus.sh
#
#############################################################################
# Copyright (c) 2009-2020 Open Source Geospatial Foundation (OSGeo) and others.
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

### set the desktop background, turn on keyboard layout select control
# sed -i -e 's|^bg=.*|bg=/usr/share/lubuntu/wallpapers/osgeo-desktop.png|' \
#        -e 's|^keyboard=0$|keyboard=1|' \
#     /etc/xdg/lubuntu/lxdm/lxdm.conf

# Actually, I think this is the one which really does it:
sed -i -e 's|^DesktopShortcuts=.*|DesktopShortcuts=Home, Trash|' \
       -e 's|^WallpaperMode=.*|WallpaperMode=stretch|' \
       -e 's|^Wallpaper=.*|Wallpaper=/usr/share/lubuntu/wallpapers/osgeo-desktop-transparent.png|' \
       -e 's|^BgColor=.*|BgColor=#000000|' \
       -e 's|^FgColor=.*|FgColor=#ffffff|' \
       -e 's|^ShadowColor=.*|ShadowColor=#000000|' \
       -e 's|^UseTrash=.*|UseTrash=true|' \
   /etc/xdg/xdg-Lubuntu/pcmanfm-qt/lxqt/settings.conf

## Desktop shadow configuration ^^
##        -e 's|^desktop_shadow=.*|desktop_shadow=#A09A8F|' \

## Removed this for xenial: -e 's|^desktop_shadow=.*|desktop_shadow=.*\nshow_mounts=1|' \

# echo "desktop_folder_new_win=1" >> /etc/xdg/pcmanfm/lubuntu/pcmanfm.conf


# New way to set login screen background as of 20.04 that uses sddm instead of lightdm
sed -i -e 's|^background=.*|background=/usr/share/lubuntu/wallpapers/osgeo-desktop-transparent.png|' \
   /usr/share/sddm/themeas/lubuntu/theme.conf

#Done:support for headless installs with or without user existing, preference for png
#Only works if user is not logged into XFCE session
# Puts the desktop background into the spot where it would be used for new user creation
#mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
#cp ../desktop-conf/xfce/xfce4-desktop.xml \
#     /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

# edit it in the skel dirs too, for the chroot method
#sed -i -e 's/xubuntu-.*.png/osgeo-desktop.png/' \
#  /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
#cp -f ../desktop-conf/xfce/xfce4-desktop.xml \
#     /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/

#Copy it to the existing user
#mkdir -p "$USER_HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/
#cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
#     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"

#chown "$USER_NAME"."$USER_NAME" \
#     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"

#Old version in case we need to revert, or if you're logged into the current XFCE session
#Has to been run as the regular user
#sudo -u $USER_NAME xfconf-query -c xfce4-desktop \
#     -p /backdrop/screen0/monitor0/image-path \
#     -s /usr/share/lubuntu/wallpapers/osgeo-desktop.png
# set to stretch style background
#sudo -u $USER_NAME xfconf-query -c xfce4-desktop --create \
#     -p /backdrop/screen0/monitor0/image-style  -s 3  -t int


# if you want panel transparency turned off edit Apps->Settings->WM Tweaks or
#  /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#         ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#    <property name="use_compositing" type="bool" value="true"/>
##sed -i -e 's|\(use_compositing" type="bool" value\)="true"|\1="false"|' \
##   /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml



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

mkdir -p "$USER_HOME"/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   "$USER_HOME"/.config/autostart/
mkdir -p /etc/skel/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   /etc/skel/.config/autostart/

cp "$BUILD_DIR/../desktop-conf/welcome_message.sh" \
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


# #### Make Unity Usable (Muu..)
# # we are using xubuntu so it's a bit academic, but in case anyone wants to
# #  use OSGeo on stock Ubuntu these changes can make it a lot less annoying.
# if [ "$DESKTOP_SESSION" = "Unity" ] ; then
#   apt-get install --yes gconf-editor dconf-tools

#   # The hardest part is finding where the heck the gnome people hid the option.
#   # To locate what you are looking for (e.g. setting the icon_size) search through:
#   #gconftool --dump /apps | grep -w -B5 -A5 icon_size
#   # more options can be found here:
#   #dconf dump / | less
#   # See also:
#   # http://www.tuxgarage.com/2011/07/customizing-gnome-lock-screen.html
#   # http://www.tuxgarage.com/2011/05/customize-gdm-plymouth-grub2.html
#   # http://library.gnome.org/admin/system-admin-guide/stable/dconf-profiles.html.en

#   # set the web browser homepage:
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/opt/gnome/gconf/gconf.xml.mandatory \
#     --type string --set /apps/firefox/general/homepage_url live.osgeo.org

#   # make the launcher icons smaller, this isn't a touchscreen
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#     --type int --set /apps/compiz-1/plugins/unityshell/screen0/options/icon_size 38
#   #also you might check the setting here: (same goes for other options too)
#   #  --type int --set /apps/compizconfig-1/profiles/Default/plugins/unityshell/screen0/options/icon_size 38

#   # only put a launcher bar on one monitor (maybe nice for laptop+monitor but bad for dual headed setups)
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#     --type int --set /apps/compiz-1/plugins/unityshell/screen0/options/num_launchers 1
  
#   # don't be sticky at the edge of the monitor (another huge frustration for dual-headed monitors)
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#     --type bool --set /apps/compiz-1/plugins/unityshell/screen0/options/launcher_capture_mouse false
  
#   # keep windows stacked as you left them,
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#     --type bool --set /apps/metacity/general/auto_raise false
  
#   # don't maximize if the window happens to brush the top of the screen while moving it
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#     --type int --set /apps/compiz-1/plugins/grid/screen0/options/top_edge_action 0
  
#   # right mouse button exists for the context menu, no need to waste the screen real estate
#   gconftool-2 --direct \
#     --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
#       --type bool --set /apps/gnome-terminal/profiles/Default/default_show_menubar false


#   # dconf weirdness:
#   mkdir -p /etc/dconf/db/local.d
#   mkdir -p /etc/dconf/profile
#   # basic setup for local mods:
#   cat << EOF > /etc/dconf/profile/user
# user-db:user
# system-db:local
# EOF
#   cat << EOF > /etc/dconf/profile/gdm
# user
# gdm
# EOF

#   # set the default desktop background:
#   cat << EOF > /etc/dconf/db/local.d/00_default-wallpaper
# [org/gnome/desktop/background]
# #picture-options='zoom'
# picture-uri='file:///usr/share/backgrounds/Precise_Pangolin_by_Vlad_Gerasimov.jpg'
# EOF

#   # set the default login background image when Unity-greeter is used by lightdm:
#   cat << EOF > /usr/share/glib-2.0/schemas/com.canonical.unity-greeter.gschema.override
# [com.canonical.unity-greeter]
# draw-user-backgrounds=false
# background='/usr/share/lubuntu/wallpapers/osgeo-desktop.png'
# EOF
#   glib-compile-schemas /usr/share/glib-2.0/schemas/

#   # set what icons will be on the taskbar (launcher) by default for new users
#   cat << EOF > /etc/dconf/db/local.d/01_unity_favorites
# [desktop/unity/launcher]
# favorites=['nautilus-home.desktop', 'firefox.desktop', 'libreoffice-writer.desktop', 'libreoffice-calc.desktop', 'gnome-control-center.desktop', 'gnome-terminal.desktop', 'nedit.desktop']
# EOF

#   # blank screen after 5 minutes
#   cat << EOF > /etc/dconf/db/local.d/02_5min_timeout
# [org/gnome/desktop/session]
# idle-delay=uint32 300

# [org/gnome/settings-daemon/plugins/power]
# sleep-display-ac=300
# sleep-display-battery=300
# EOF

#   # apply the changes to the dconf DB
#   dconf update
# fi


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
