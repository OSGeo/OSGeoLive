#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
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
# This script will create a bootable iso from the current running system

# Running:
# Note: Run this absolutely last, especially after doing filesystem cleanup
# =======
# sudo ./build_iso.sh
#

USER_NAME="user"
USER_HOME="/home/$USER_NAME"
DIR=`dirname ${0}`
VERSION=`cat "$DIR"/../VERSION.txt`
PACKAGE_NAME="osgeo-live"
ISO_NAME="${PACKAGE_NAME}-${VERSION}"
WORKDIR="/tmp/remastersys"
TMP="$WORKDIR/ISOTMP"
LOGS="/var/log/osgeolive/remastersys.conf"
DOCS_SRC="/var/www"


# Install remastersys.sh add directories it expects
mkdir -p $TMP
mkdir -p $WORKDIR/ISOTMP/casper
mkdir -p $WORKDIR/ISOTMP/preseed
mkdir -p $WORKDIR/dummysys/dev
mkdir -p $WORKDIR/dummysys/etc
mkdir -p $WORKDIR/dummysys/proc
mkdir -p $WORKDIR/dummysys/tmp
mkdir -p $WORKDIR/dummysys/sys
mkdir -p $WORKDIR/dummysys/mnt
mkdir -p $WORKDIR/dummysys/media/cdrom
mkdir -p $WORKDIR/dummysys/var
chmod ug+rwx,o+rwt "$WORKDIR"/dummysys/tmp

wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_5/sources.list.d/remastersys.list \
     --output-document=/etc/apt/sources.list.d/remastersys.list

# apt-get update
apt-get update

# no !@#$%!%#@ GPG key
apt-get --assume-yes --force-yes install remastersys

# Configure
# ie set exclude folders in /etc/remastersys.conf
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/branches/osgeolive_5_5/app-data/remastersys.conf \
     --output-document="$LOGS"
cp "$LOGS" /etc/remastersys.conf

# grab copy of custom isolinux - disabled until fixed
#wget -nv http://osprey.ucdavis.edu/downloads/osgeo/gisvm/isolinux.tar.gz \
#	--output-document="$WORKDIR"/isolinux.tar.gz

#tar xzf "$WORKDIR"/isolinux.tar.gz  -C "$WORKDIR"
#cp -R  "$WORKDIR"/isolinux/* /etc/remastersys/customisolinux/
#Not sure if this is necessary but can't hurt to make them read only
#chmod -R uga-w /etc/remastersys/customisolinux/

#TODO: if not mini include, else rm ISOTMP/Mac&Win folders to make sure it's a mini
if [ "$1" != "mini" ] ; then
	# Add Windows and Mac installers by copying files into ISOTMP folder
	./load_win_installers.sh
	./load_mac_installers.sh
fi

# Copy documentation
cp -pr "$DOCS_SRC" "${TMP}/osgeolive-docs"


############################################
#### 5.0rc3:  logout, shutdown, and reboot seem broken on the ISO.
# offer some emergency alternatives.
cat << EOF > /home/user/Desktop/osgeo-logout.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Log out
Comment=Takes you back to the login screen (in case the menu item is broken)
Categories=Application;
Exec=killall xfce4-session
Icon=system-log-out
Terminal=false
EOF

cat << EOF > /home/user/Desktop/osgeo-reboot.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Reboot
Comment=Reboots the system (in case the menu item is broken)
Categories=Application;
Exec=/usr/local/bin/osgeo-reboot.sh
Icon=reload
Terminal=false
EOF

cat << EOF > /home/user/Desktop/osgeo-halt.desktop
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Shut down
Comment=Shut down the system (in case the menu item is broken)
Categories=Application;
Exec=/usr/local/bin/osgeo-halt.sh
Icon=gnome-session-halt
Terminal=false
EOF

chown user.user /home/user/Desktop/osgeo-*.desktop

cat << EOF > /usr/local/bin/osgeo-reboot.sh
#!/bin/sh
sync
echo user | sudo -S reboot
EOF
chmod a+x /usr/local/bin/osgeo-reboot.sh

cat << EOF > /usr/local/bin/osgeo-halt.sh
#!/bin/sh
sync
echo user | sudo -S halt
EOF
chmod a+x /usr/local/bin/osgeo-halt.sh
############################################


# save space on ISO by removing the .svn/ dirs
#   (or control this in bootstrap.sh by uncommenting the 'svn export' line)
for DIR in `find /usr/local/share/gisvm | grep '\.svn$'` ; do
   rm -rf "$DIR"
done


# For security reasons these must be removed.
#  If you need them, generate fresh ones with:
#    sudo ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
#    sudo ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
# This is a fail-safe repeat of the action which happens in install_services.sh
rm -rf /etc/ssh/ssh_host_[dr]sa_key*


# To save space merge duplicates in /usr, /opt, and /lib using hardlinks
echo "Hardlinking duplicate files in /usr, /opt, and /lib ..."
df -h /usr /opt /lib | uniq # report how much place is free before hardlinking
/usr/share/fslint/fslint/findup -m /usr /opt /lib
df -h /usr /opt /lib | uniq # report how much place is free after hardlinking

# Update the file search index
updatedb



#Copy the home dir to /etc/skel
#cp -RnpP ${USER_HOME}/* /etc/skel/
#chown -RP root:root /etc/skel/

#TMP fix for bug in 2.0.18-1
sed -i -e 's:rm -rf $WORKDIR/dummysys/etc/gdm/custom.conf:#Removed:' /usr/bin/remastersys

# Create iso, only uncomment once it's working, currently backup mode, TODO: convert to dist mode
# TODO: if mini name it mini
if [ "$1" = "mini" ] ; then
	# quick name check
	ISO_NAME="${PACKAGE_NAME}-mini-${VERSION}"
	echo "Now creating ${ISO_NAME}.iso"
	remastersys backup ${ISO_NAME}.iso
else
	# quick name check
	echo "Now creating $ISO_NAME.iso"
	remastersys backup "$ISO_NAME.iso"
fi
