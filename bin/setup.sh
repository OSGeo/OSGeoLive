#!/bin/sh
#############################################################################
#
# Purpose: This script will take a raw Lubuntu system and update it ready to run
# OSGeoLive install scripts.
#
#############################################################################
# Copyright (c) 2009-2015 Open Source Geospatial Foundation (OSGeo)
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

# if [ "`uname -m`" != "i686" ] ; then
#    echo "WARNING: Current system is not i686; any binaries built may be tied to current system (`uname -m`)"
# fi
# look for ./configure --build=BUILD, --host=HOST, --target=TARGET  to try and force build for i686.
# For .deb package building something like: 'debuild binary-arch i686' ???????

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


## tests for #1334
echo --
ls -l /boot
echo --
update-initramfs -u
echo --
ls -l /boot
echo --

# Pin down kernel version
echo "linux-image-generic hold" | dpkg --set-selections

# # Temporary fix for #1362: block resolvconf updates
# echo "resolvconf hold" | dpkg --set-selections

# Install latest greatest security packages etc.
apt-get -q update

# work-around for ubu pkg breakage ver 204-5ubuntu20.2 (see trac #1334)
sed -i -e 's/exit $?/exit 0/' \
   "/var/lib/dpkg/info/libpam-systemd:i386.prerm"
sed -i -e 's/exit $?/exit 0/' \
   "/var/lib/dpkg/info/libpam-systemd:amd64.prerm"
service systemd-logind stop

apt-get --yes install systemd-services

sed -i -e 's/exit $?/exit 0/' \
   "/var/lib/dpkg/info/libpam-systemd:i386.postinst"
sed -i -e 's/exit $?/exit 0/' \
   "/var/lib/dpkg/info/libpam-systemd:amd64.postinst"

apt-get --yes install libpam-systemd
apt-get -f install --yes

# argh, whoopsie has the same missing init.d script bug.
sed -i -e 's/exit $?/exit 0/' \
   "/var/lib/dpkg/info/whoopsie.prerm"
apt-get --yes remove whoopsie libwhoopsie0


###
echo "[before apt-get upgrade]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf
###

apt-get --yes upgrade

### did we loose DNS?? (#1362)
echo "[before dhclient]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf

dhclient eth0

echo "[after dhclient]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf

apt-get --yes -f install

echo "[after apt-get -f install]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf

echo "[before dhclient]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf

dhclient eth0

echo "[after dhclient]"
ls -l /etc/resolv.conf /run/resolvconf/resolv.conf

echo "----"
nslookup live.osgeo.org
echo "----"
cat /etc/resolv.conf
echo "----"
cat /run/resolvconf/resolv.conf
echo "----"

###


# Add OSGeoLive repository

# FIXME: To be removed when OSGeoLive ppa is populated
#cp ../sources.list.d/ubuntugis.list /etc/apt/sources.list.d/

if [ "$BUILD_MODE" = "release" ] ; then
   cp ../sources.list.d/osgeolive.list /etc/apt/sources.list.d/
   # cp ../sources.list.d/osgeolive-nightly.list /etc/apt/sources.list.d/
else
   cp ../sources.list.d/osgeolive-nightly.list /etc/apt/sources.list.d/
fi

#Add keys for repositories
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 314DF160
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FADA29F7
# Staging repo
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6EB3B214

apt-get -q update


# Install some useful stuff
apt-get install --yes wget less zip unzip bzip2 p7zip \
  cvs cvsutils subversion subversion-tools mercurial git \
  openssh-client lftp sl usbutils wireless-tools \
  locate patch fuseiso menu dlocate \
  vim medit nedit nano screen iotop xfonts-jmk \
  ghostscript a2ps netpbm qiv htop \
  lynx mutt mc xchat rxvt units scrot \
  gdebi fslint arandr sgt-puzzles sopwith xkb-data \
  xfonts-100dpi xfonts-75dpi

# smallish KDE apps to install only if KDE libs are already present:
#apt-get install --yes okular filelight

# some xfce desktop widgets for i18n and laptops
#apt-get install --yes xfce4-xkb-plugin xfce4-power-manager \
#   xfce4-wavelan-plugin xfce4-battery-plugin


# needed for installing packages for workshops (http://wiki.osgeo.org/wiki/Workshops_with_OSGeoLive)
apt-get install --yes apturl

# Install build stuff (temporarily?)
apt-get install --yes gcc build-essential devscripts pbuilder fakeroot \
  svn-buildpackage lintian debhelper pkg-config dpkg-dev cmake

# Install virtualbox guest additions
# If running on virtualbox this will allow us to use full-screen/usb2/...
# If running outside virtualbox the drivers will not be loaded
apt-get install --yes virtualbox-guest-dkms virtualbox-guest-x11 virtualbox-guest-utils

# install the python .deb maker
apt-get install --yes python-stdeb python-all-dev

# Need newer version of URL python-stdeb since python.org changed URLs
#  https://bugs.launchpad.net/ubuntu/+source/stdeb/+bug/1316521
sed -i -e 's+http://python.org/pypi+http://pypi.python.org/pypi+' \
  /usr/bin/pypi-install


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
apt-get remove --yes \
   gimp gimp-data gimp-help-common gimp-help-en libgimp2.0 \
   thunderbird pidgin-data hplip hplip-data \
   gnome-user-guide xfwm4-themes libsane \
   libsane-common libsane-hpaio libieee1284-3 \
   libwebkitgtk-1.0-0 libwebkitgtk-1.0-common libjavascriptcoregtk-1.0.0

# sadly, uninstall samba as we need the disc space. priority for
#  re-adding if we can find the room  (~85mb uncompressed)
#apt-get --assume-yes remove smbclient samba-common-bin


# since GIMP is removed we have to replace an xUbuntu default icon
# software store and related bloat removed, use synaptic instead
#sed -i -e 's+ubuntu-software-center\.desktop+synaptic\.desktop+' \
#   /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml
#sed -i -e 's+ubuntu-software-center\.desktop+synaptic\.desktop+' \
#   /etc/xdg/xdg-xubuntu/menus/xfce-applications.menu

# remove xscreensaver as it tends to saturate VM bandwidth
#apt-get --assume-yes remove xscreensaver

#buggy in 12.04:
# but does it want to take the rest of the xubuntu desktop with it?
#apt-get remove --yes blueman

# this will clear out 96mb (uncompressed), but users who want the
# nvidia proprietary driver will need to reinstall it. ah well.
#Version must be kept up to date (removes 3 packages)
##apt-get --assume-yes remove linux-headers-generic
##apt-get --assume-yes remove linux-headers-3.13.0-32
# ...
#apt-get --assume-yes remove linux-headers-3.13.0-33

#temp to get past dep blockage
#apt-get --assume-yes install libgrip0

# regen initrd
depmod

# Remove unused home directories
#?? rm -fr "$USER_HOME"/Downloads
#rm -fr "$USER_HOME"/Documents
#rm -fr "$USER_HOME"/Pictures
rm -fr "$USER_HOME"/Music
rm -fr "$USER_HOME"/Public
rm -fr "$USER_HOME"/Templates
rm -fr "$USER_HOME"/Videos
# and don't come back now
apt-get --assume-yes remove xdg-user-dirs

# .. and remove any left-over package cruft
apt-get --assume-yes autoremove


# rename dangerous icon
# this probably won't work here because ubiquity isn't loaded until remastersys step
if [ -e /usr/share/applications/ubiquity-gtkui.desktop ] ; then
   sed -i -e 's/^Name=Install/Name=Install OSGeoLive Linux based on/' \
      /usr/share/applications/ubiquity-gtkui.desktop
fi

# while we're at, avoid ubiquity installer coming up at boot time
sed -i -e '11,15d' -e 's/^start on .*/#start on/' /etc/init/ubiquity.conf


# Link to the project data files
cd "$USER_HOME"
mkdir -p /usr/local/share/data --verbose
ln -s /usr/local/share/data data
chown -h "$USER_NAME":"$USER_NAME" data
ln -s /usr/local/share/data /etc/skel/data


# and there was music and laughter and much rejoicing
adduser user audio
# and connectivity too
adduser user fuse

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


### temporary ubuntu 14.04 DNS bug work-around
# move into /etc as needed
echo "nameserver 8.8.8.8" > /etc/skel/resolv.conf
# another thing to try:
#echo "dhclient eth0" > /etc/network/if-up.d/001resolvconf_override
#chmod a+r /etc/network/if-up.d/001resolvconf_override


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
