#!/bin/sh
#############################################################################
#
# Purpose: This script will take a raw Lubuntu system and update it ready to run
# OSGeoLive install scripts.
#
#############################################################################
# Copyright (c) 2009-2021 Open Source Geospatial Foundation (OSGeo) and others.
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

if [ "$1" != "release" ] && [ "$1" != "nightly" ] ; then
   echo "Did not specify build mode, try using release or nightly as an argument"
   exit 1
fi
BUILD_MODE="$1"

./diskspace_probe.sh "`basename $0`" begin
./diskspace_probe.sh "`basename $0`"
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo "Running setup.sh with the following settings:"
echo "BUILD_MODE: $BUILD_MODE"

# don't install the kitchen sink
if [ ! -e /etc/apt/apt.conf.d/depends_only ] ; then
   cat << EOF > /etc/apt/apt.conf.d/depends_only
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF
fi

# only look for updates once a week
sed -i -e 's|\(APT::Periodic::Update-Package-Lists\) "1";|\1 "7";|' \
   /etc/apt/apt.conf.d/10periodic

# Pin down kernel version
echo "linux-image-generic hold" | dpkg --set-selections
# echo "linux-signed-generic-hwe-18.04 hold" | dpkg --set-selections

# Install latest greatest security packages etc.
apt-get -q update
#FIXME: Enable updates after beta
# apt-get --yes upgrade

# Remove snapd applications and service
# snap remove --purge firefox
# snap remove --purge gnome-3-38-2004
# snap remove --purge gtk-common-themes
# snap remove --purge bare
# snap remove --purge core20
# snap remove --purge snapd
apt-get remove --yes snapd
umount /snap/firefox/1232
umount /snap/gnome-3-38-2004/99
umount /snap/gtk-common-themes/1534
umount /snap/bare/5
umount /snap/core20/1405
umount /snap/snapd/15177
#rm -rf /var/lib/snapd/snaps/*.snap
rm -rf /var/lib/snapd
rm -rf /var/cache/snapd
rm -rf /etc/systemd/system/snap-*.mount
rm /etc/udev/rules.d/70-snap*.rules

# This will prevent snapd from any repository
cp ../app-conf/apt/nosnap.pref /etc/apt/preferences.d/
cp ../app-conf/apt/firefox-nosnap.pref /etc/apt/preferences.d/

# Add OSGeoLive repository
if [ "$BUILD_MODE" = "release" ] ; then
   cp ../sources.list.d/osgeolive.list /etc/apt/sources.list.d/
   # cp ../sources.list.d/osgeolive-nightly.list /etc/apt/sources.list.d/
else
   cp ../sources.list.d/osgeolive-nightly.list /etc/apt/sources.list.d/
fi

# Add Mozilla repository
cp ../sources.list.d/mozilla.list /etc/apt/sources.list.d/

# Add keys for repositories
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys FADA29F7
# Staging repo
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6EB3B214
# UbuntuGIS
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
# Mozilla ppa
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE49EC21

apt-get -q update


# Install some useful stuff
apt-get install --yes wget less zip unzip bzip2 p7zip \
  git openssh-client lftp usbutils wireless-tools \
  locate patch menu vim nano screen iotop xfonts-jmk \
  ghostscript htop units gdebi xkb-data \
  xfonts-100dpi xfonts-75dpi zenity curl firefox

# removed from list:
# cvs cvsutils fuseiso dlocate medit nedit a2ps netpbm qiv lynx mutt mc
# xchat rxvt scrot arandr sgt-puzzles sopwith subversion subversion-tools
# mercurial

# Install virtualbox guest additions
# If running on virtualbox this will allow us to use full-screen/usb2/...
# If running outside virtualbox the drivers will not be loaded
# apt-get install --yes virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
# apt-get install --yes virtualbox-guest-dkms-hwe virtualbox-guest-utils-hwe virtualbox-guest-x11-hwe

##-------
# add /usr/local/lib to /etc/ld.so.conf if needed, then run ldconfig
# FIXME: similar thing needed for man pages?
# Ubuntu 1804 - this is no longer an issue, path exists in /etc/ld.so.conf.d/libc.conf
## -- for reference only --
#if [ -d /etc/ld.so.conf.d ] ; then
#   echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
#else
#   if [ `grep -c '/usr/local/lib' /etc/ld.so.conf` -eq 0 ] ; then
#      echo "/usr/local/lib" >> /etc/ld.so.conf
#   fi
#fi
#ldconfig
##-------

# so we can see why things fail to start..
## Ubuntu 1804 - does not exist
#sed -i -e 's/^VERBOSE=no/VERBOSE=yes/' /etc/default/rcS


# for list of packages taking up the most space install the debian-goodies
#    package to get `dpigs`. or try `wajig size`

# Uninstall large applications installed by default
apt-get remove --yes \
   libsane1 libsane-common libsane-hpaio libieee1284-3

# regen initrd
depmod

# Remove unused home directories
#rm -fr "$USER_HOME"/Downloads
#rm -fr "$USER_HOME"/Documents
rm -fr "$USER_HOME"/Pictures
rm -fr "$USER_HOME"/Music
rm -fr "$USER_HOME"/Public
rm -fr "$USER_HOME"/Templates
rm -fr "$USER_HOME"/Videos
# and don't come back now
# apt-get --assume-yes remove xdg-user-dirs

# .. and remove any left-over package cruft
apt-get --assume-yes autoremove


# Link to the project data files
cd "$USER_HOME"
mkdir -p /usr/local/share/data --verbose
ln -s /usr/local/share/data data
chown -h "$USER_NAME":"$USER_NAME" data
ln -s /usr/local/share/data /etc/skel/data

# and there was music and laughter and much rejoicing
adduser user audio

## https://bugs.launchpad.net/ubuntu/+source/fuse/+bug/1581163
# and connectivity too
#adduser user fuse

# highly useful tricks
#  (/etc/skel/.bashrc seems to be clobbered by the copy in USER_HOME)
# TODO: write to ~/.bash_aliases instead
cat << EOF >> "$USER_HOME"/.bashrc

# help avoid dumb mistakes
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

EOF
sed -i -e 's/ls --color=auto/ls --color=auto -F/' "$USER_HOME"/.bashrc
chown "$USER_NAME":"$USER_NAME" "$USER_HOME"/.bashrc


# make it easy for users to edit in a general proxy setting
#   perhaps more robust: demo how to set up a (disabled) transparent proxy?
if [ `grep -c http_proxy "/etc/skel/.profile"` -eq 0 ] ; then
   cat << EOF >> "/etc/skel/.profile"

### Edit then uncomment the following lines to direct traffic through a proxy server:
###   example:   http_proxy="http://proxy.example.com:8001"
#http_proxy="http://[username[:password]@]server.example.com:port/"
#https_proxy="$http_proxy"
#ftp_proxy="$ftp_proxy"
#export http_proxy https_proxy ftp_proxy

EOF
fi

if [ `grep -c http_proxy "$USER_HOME/.profile"` -eq 0 ] ; then
   cat << EOF >> "$USER_HOME/.profile"

### Edit then uncomment the following lines to direct traffic through a proxy server:
###   example:   http_proxy="http://proxy.example.com:8001"
#http_proxy="http://[username[:password]@]server.example.com:port/"
#https_proxy="$http_proxy"
#ftp_proxy="$ftp_proxy"
#export http_proxy https_proxy ftp_proxy

EOF
fi


cat << EOF >> "$USER_HOME"/.inputrc
# a conference talk full of terminal beeps is no good
set prefer-visible-bell

# -------- Bind page up/down with history search ---------
"\e[5~": history-search-backward
"\e[6~": history-search-forward
EOF
chown "$USER_NAME":"$USER_NAME" "$USER_HOME"/.inputrc
cp "$USER_HOME"/.inputrc /etc/skel/
cp "$USER_HOME"/.inputrc /root/


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
