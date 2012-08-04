#!/bin/sh
# Copyright (c) 2009-2012 The Open Source Geospatial Foundation.
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
# This script will take a raw Xubuntu system and update it ready to run
# GISVM install scripts.

# Running:
# =======
# sudo ./setup.sh

if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"


if [ "`uname -m`" != "i686" ] ; then
   echo "WARNING: Current system is not i686; any binaries built may be tied to current system (`uname -m`)"
fi
# look for ./configure --build=BUILD, --host=HOST, --target=TARGET  to try and force build for i686.
# For .deb package building something like: 'debuild binary-arch i686' ???????

# don't install the kitchen sink
if [ ! -e /etc/apt/apt.conf.d/depends_only ] ; then
   cat << EOF > /etc/apt/apt.conf.d/depends_only
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF
fi


# Install latest greatest security packages etc.
#Deactivated since it breaks chroot build method.
#apt-get -q update && apt-get --yes upgrade
apt-get -q update

# Add UbuntuGIS repository
cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

#Add signed key for repositorys LTS and non-LTS
#qgis repo 68436DDF unused? :
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68436DDF  
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160  
apt-get -q update


# Install some useful stuff
apt-get install --yes wget less zip unzip bzip2 p7zip \
  cvs cvsutils subversion subversion-tools mercurial git \
  openssh-client lftp sl usbutils wireless-tools \
  locate diff patch fuseiso menu \
  vim medit nedit nano screen iotop xfonts-jmk \
  okular ghostscript a2ps netpbm qiv \
  lynx mutt mc xchat rxvt units scrot \
  gdebi fslint filelight arandr sgt-puzzles

# some xfce desktop widgets for i18n and laptops
apt-get install --yes xfce4-xkb-plugin xfce4-power-manager \
   xfce4-wavelan-plugin xfce4-battery-plugin


# Install build stuff (temporarily?)
apt-get install --yes gcc build-essential devscripts pbuilder fakeroot \
  svn-buildpackage lintian debhelper pkg-config dpkg-dev cmake


# add /usr/local/lib to /etc/ld.so.conf if needed, then run ldconfig
# FIXME: similar thing needed for man pages?
if [ -d /etc/ld.so.conf.d ] ; then
   echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
else
   if [ `grep -c '/usr/local/lib' /etc/ld.so.conf` -eq 0 ] ; then
      echo "/usr/local/lib" >> /etc/ld.so.conf
   fi
fi
ldconfig


# so we can see why things fail to start..
sed -i -e 's/^VERBOSE=no/VERBOSE=yes/' /etc/default/rcS


# for list of packages taking up the most space install the debian-goodies
#    package to get `dpigs`. or try `wajig size`

# Uninstall large applications installed by default
apt-get remove --yes gnome-games-common \
   gimp gimp-data gimp-help-common gimp-help-en libgimp2.0 \
   libgegl-0.0.0 libbabl-0.0.0 libotr2 \
   thunderbird pidgin-data hplip hplip-data \
   gnome-user-guide xfwm4-themes libsane \
   libsane-common libsane-hpaio libieee1284-3 \
   libwebkitgtk-1.0-0 libwebkitgtk-1.0-common libjavascriptcoregtk-1.0.0

# sadly, uninstall samba as we need the disc space. priority for
#  re-adding if we can find the room  (~85mb uncompressed)
apt-get --assume-yes remove smbclient samba-common-bin


# since GIMP is removed we have to replace an xUbuntu default icon
# software store and related bloat removed, use synaptic instead
sed -i -e 's+gimp\.desktop+xfce4-dict\.desktop+' \
       -e 's+ubuntu-software-center\.desktop+synaptic\.desktop+' \
   /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml
sed -i -e 's+ubuntu-software-center\.desktop+synaptic\.desktop+' \
   /etc/xdg/xdg-xubuntu/menus/xfce-applications.menu

# remove xscreensaver as it tends to saturate VM bandwidth
apt-get --assume-yes remove xscreensaver

# pls add "why" here
apt-get remove --yes indicator-messages

#buggy in 12.04:
# but does it want to take the rest of the xubuntu desktop with it?
apt-get remove --yes blueman

# this will clear out 96mb (uncompressed), but users who want the
# nvidia proprietary driver will need to reinstall it. ah well.
#Version must be kept up to date (removes 3 packages)
apt-get --assume-yes remove linux-headers-3.2.0-27
apt-get --assume-yes remove linux-headers-3.2.0-26
apt-get --assume-yes remove linux-headers-3.2.0-25
apt-get --assume-yes remove linux-headers-3.2.0-24
apt-get --assume-yes remove linux-headers-3.2.0-23


# Remove unused home directories
#?? rm -fr "$USER_HOME"/Downloads
rm -fr "$USER_HOME"/Documents
rm -fr "$USER_HOME"/Music
rm -fr "$USER_HOME"/Pictures
rm -fr "$USER_HOME"/Public
rm -fr "$USER_HOME"/Templates
rm -fr "$USER_HOME"/Videos

# rename dangerous icon
# this probably won't work here because ubiquity isn't loaded until remastersys step
if [ -e /usr/share/applications/ubiquity-gtkui.desktop ] ; then
   sed -i -e 's/Install/Install xubuntu GNU Linux/' \
      /usr/share/applications/ubiquity-gtkui.desktop
fi

# Link to the project data files
cd "$USER_HOME"
mkdir -p /usr/local/share/data --verbose
ln -s /usr/local/share/data data
chown "$USER_NAME":"$USER_NAME" data
ls -s /usr/local/share/data/ /etc/skel/data


# and there was music and laughter and much rejoicing
adduser user audio

# highly useful tricks
echo "alias ll='ls -l'" >> "$USER_HOME"/.bashrc
chown "$USER_NAME":"$USER_NAME" "$USER_HOME"/.bashrc
echo "alias ll='ls -l'" >> /etc/skel/.bashrc

# help avoid dumb mistakes
echo "alias cp='cp -i'" >> /etc/skel/.bashrc
echo "alias mv='mv -i'" >> /etc/skel/.bashrc
echo "alias rm='rm -i'" >> /etc/skel/.bashrc


cat << EOF >> "$USER_HOME"/.inputrc
# a conference talk full of terminal beeps is no good
set prefer-visible-bell

# -------- Bind page up/down wih history search ---------
"\e[5~": history-search-backward
"\e[6~": history-search-forward
EOF
chown "$USER_NAME":"$USER_NAME" "$USER_HOME"/.inputrc
cp "$USER_HOME"/.inputrc /etc/skel/
cp "$USER_HOME"/.inputrc /root/

