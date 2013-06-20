#!/bin/sh
# Copyright (c) 2009-2013 The Open Source Geospatial Foundation.
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

# About:
# =====
# This script will install a desktop background image, password file,
# taskbar,and generally clean up the user desktop-interface experience.
# The menu creation and icon sorting has moved to install_icons_and_menus.sh
#

SCRIPT="install_desktop.sh"
echo "==============================================================="
echo "$SCRIPT"
echo "==============================================================="

# Running:
# =======
# sudo ./install_desktop.sh
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BUILD_DIR=`pwd`



# Default password list on the desktop to be replaced by html help in the future.
cp ../doc/passwords.txt "$USER_HOME/Desktop/"
chown "$USER_NAME"."$USER_NAME" "$USER_HOME/Desktop/passwords.txt"


# Setup the desktop background image
cp ../desktop-conf/osgeo-desktop.png \
   /usr/share/xfce4/backdrops

#New way to set login screen background as of 12.04 that uses lightdm instead of gdm
# (awaiting graphic with text overlay explaining what the user name and password is)
sed -i -e 's|^background=.*|background=/usr/share/xfce4/backdrops/osgeo-desktop.png|' \
   /etc/lightdm/lightdm-gtk-greeter.conf

#Done:support for headless installs with or without user existing, preference for png
#Only works if user is not logged into XFCE session
# Puts the desktop background into the spot where it would be used for new user creation
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
cp ../desktop-conf/xfce/xfce4-desktop.xml \
     /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
#Copy it to the existing user
mkdir -p "$USER_HOME"/.config/xfce4/xfconf/xfce-perchannel-xml/
cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
#Note: Style int 3 means stretched
#Not sure if this is necessary
chown "$USER_NAME"."$USER_NAME" \
     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"

# edit it in the skel dirs too, for the chroot method
sed -i -e 's/xubuntu-.*.png/osgeo-desktop.png/' \
  /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

#Old version in case we need to revert, or if you're logged into the current XFCE session
#Has to been run as the regular user
#sudo -u $USER_NAME xfconf-query -c xfce4-desktop \
#     -p /backdrop/screen0/monitor0/image-path \
#     -s /usr/share/xfce4/backdrops/osgeo-desktop.png
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
echo "TODO: update autologin preferences for lightdm."
#cp "$BUILD_DIR"/../desktop-conf/custom.conf /etc/gdm/custom.conf


##### Setup timed welcome message
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

if [ -e "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.txt ] ; then
  cp "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
else
  cp "$BUILD_DIR/../doc/en"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
fi

cp /usr/local/share/osgeo-desktop/welcome_message.txt "$USER_HOME"/
chown "$USER_NAME"."$USER_NAME" "$USER_HOME"/welcome_message.txt
cp /usr/local/share/osgeo-desktop/welcome_message.txt /etc/skel/


if [ 'softly' = 'yes' ] ; then
   # FOSS the Software Center
   cd /usr/share/software-center/
   patch -p0 -N -r - --quiet < "$BUILD_DIR/../desktop-conf/FOSScenter.patch"
   PYCs=`grep ORIG FOSScenter.patch | sed -e 's/\.ORIG.*//' -e 's/.[^\.]*//' -e 's/$/c/'`
   rm -f $PYCs
   #fixme:  pycompile -p ... ?? (running software-center as root will rebuild them)
   rm -rf "$USER_NAME/.cache/software-center/"
else
   # remove the bastard and free up 65-105mb
   apt-get purge --assume-yes software-center software-center-aptdaemon-plugins \
       apt-xapian-index
   rm -rf /var/cache/apt-xapian-index
fi

#### replace the Software Center on the Apps menu with the more useful Synaptic
# .. TODO   (right click the Apps menu, properties, edit, add synaptic-pkexec, 
#       name it package manager to keep the width narrow; then create a patch)
# --> see bin/setup.sh line 116 where it is replaced with sed

#### the default xUbuntu 12.04 theme has 1px wide window borders which
# makes it extremely tricky to resize them. tweak the theme so that
# window borders are 4px wide so they are easier to grab.
cp -f "$BUILD_DIR"/../desktop-conf/xfce/greybird_theme/*.xpm \
   /usr/share/themes/Greybird/xfwm4/


#### Make Unity Usable (Muu..)
# we are using xubuntu so it's a bit academic, but in case anyone wants to
#  use OSGeo on stock Ubuntu these changes can make it a lot less annoying.
if [ "$DESKTOP_SESSION" = "Unity" ] ; then
  apt-get install --yes gconf-editor dconf-tools

  # The hardest part is finding where the heck the gnome people hid the option.
  # To locate what you are looking for (e.g. setting the icon_size) search through:
  #gconftool --dump /apps | grep -w -B5 -A5 icon_size
  # more options can be found here:
  #dconf dump / | less
  # See also:
  # http://www.tuxgarage.com/2011/07/customizing-gnome-lock-screen.html
  # http://www.tuxgarage.com/2011/05/customize-gdm-plymouth-grub2.html
  # http://library.gnome.org/admin/system-admin-guide/stable/dconf-profiles.html.en

  # set the web browser homepage:
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/opt/gnome/gconf/gconf.xml.mandatory \
    --type string --set /apps/firefox/general/homepage_url live.osgeo.org

  # make the launcher icons smaller, this isn't a touchscreen
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
    --type int --set /apps/compiz-1/plugins/unityshell/screen0/options/icon_size 38
  #also you might check the setting here: (same goes for other options too)
  #  --type int --set /apps/compizconfig-1/profiles/Default/plugins/unityshell/screen0/options/icon_size 38

  # only put a launcher bar on one monitor (maybe nice for laptop+monitor but bad for dual headed setups)
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
    --type int --set /apps/compiz-1/plugins/unityshell/screen0/options/num_launchers 1
  
  # don't be sticky at the edge of the monitor (another huge frustration for dual-headed monitors)
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
    --type bool --set /apps/compiz-1/plugins/unityshell/screen0/options/launcher_capture_mouse false
  
  # keep windows stacked as you left them,
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
    --type bool --set /apps/metacity/general/auto_raise false
  
  # don't maximize if the window happens to brush the top of the screen while moving it
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
    --type int --set /apps/compiz-1/plugins/grid/screen0/options/top_edge_action 0
  
  # right mouse button exists for the context menu, no need to waste the screen real estate
  gconftool-2 --direct \
    --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
      --type bool --set /apps/gnome-terminal/profiles/Default/default_show_menubar false


  # dconf weirdness:
  mkdir -p /etc/dconf/db/local.d
  mkdir -p /etc/dconf/profile
  # basic setup for local mods:
  cat << EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF
  cat << EOF > /etc/dconf/profile/gdm
user
gdm
EOF

  # set the default desktop background:
  cat << EOF > /etc/dconf/db/local.d/00_default-wallpaper
[org/gnome/desktop/background]
#picture-options='zoom'
picture-uri='file:///usr/share/backgrounds/Precise_Pangolin_by_Vlad_Gerasimov.jpg'
EOF

  # set what icons will be on the taskbar (launcher) by default for new users
  cat << EOF > /etc/dconf/db/local.d/01_unity_favorites
[desktop/unity/launcher]
favorites=['nautilus-home.desktop', 'firefox.desktop', 'libreoffice-writer.desktop', 'libreoffice-calc.desktop', 'gnome-control-center.desktop', 'gnome-terminal.desktop', 'nedit.desktop']
EOF

  # blank screen after 5 minutes
  cat << EOF > /etc/dconf/db/local.d/02_5min_timeout
[org/gnome/desktop/session]
idle-delay=uint32 300

[org/gnome/settings-daemon/plugins/power]
sleep-display-ac=300
sleep-display-battery=300
EOF

  # apply the changes to the dconf DB
  dconf update
fi

echo "==============================================================="
echo "Finished $SCRIPT"
echo Disk Usage1:, $SCRIPT, `df . -B 1M | grep "Filesystem" | sed -e "s/  */,/g"`, date
echo Disk Usage2:, $SCRIPT, `df . -B 1M | grep " /$" | sed -e "s/  */,/g"`, `date`
echo "==============================================================="