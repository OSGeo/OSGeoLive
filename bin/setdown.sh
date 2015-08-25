#!/bin/sh
#############################################################################
#
# Purpose: This script will cleanup the system after running OSGeoLive
# install scripts.
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
# Running:
# =======
# sudo ./setdown.sh 2>&1 | tee /var/log/osgeolive/setdown.log
#############################################################################

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####


if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

DIR=`dirname "$0"`
VERSION=`cat "$DIR"/../VERSION.txt`
PACKAGE_NAME="osgeolive"
VM="${PACKAGE_NAME}-$VERSION"


# by removing the 'user', it also meant that 'user' was removed from /etc/group
#  so we have to put it back at boot time.
if [ `grep -c 'adduser' /etc/rc.local` -eq 0 ] ; then
    sed -i -e 's|exit 0||' /etc/rc.local

#   GRPS="audio dialout fuse plugdev pulse staff tomcat7 users www-data"
#bad smelling hack to mitigate the effects of #1104's race condition
    GRPS="users tomcat7 www-data staff fuse plugdev audio dialout pulse"

    for GRP in $GRPS ; do
       echo "adduser $USER_NAME $GRP" >> /etc/rc.local
    done
    echo >> /etc/rc.local
    echo "exit 0" >> /etc/rc.local
fi
# try to get those changes applied sooner
mv /etc/rc2.d/S99rc.local /etc/rc2.d/S10rc.local

# bloody hell..
cp ../app-conf/build_chroot/27osgeo_groups \
  /usr/share/initramfs-tools/scripts/casper-bottom/


# re-enable ability to create persistent USB installs on a 4gb thumb drive
sed -i -e 's/\(^MIN_PERSISTENCE =\) .*/\1 256/' \
   /usr/lib/python3/dist-packages/usbcreator/misc.py

# remove build stuff no longer of use
apt-get --yes remove devscripts pbuilder \
   svn-buildpackage \
   lintian debhelper pkg-config dpkg-dev

apt-get --yes remove python2.7-dev

# libgdal-dev, libpq-dev, and grass-dev get installed and uninstalled
# so many times it's hard to keep track. let's install them one final
# time just to be sure they make it on...
# grass-dev will depend on libgdal-dev or libgdal1-dev as needed, so
#  during the transition we'll let gdal just be implicit. libpq-dev will
#  also be pulled in automatically by this.
apt-get install --assume-yes grass-dev proj-bin


# remove any leftover orphans
apt-get --yes autoremove

# some tarball or something is making /usr group writable, which
#  makes openssh-server refuse to start.  (FIXME)
#/usr/lib/Kosmo-3.0/
chmod g-w /usr
chmod g-w /usr/bin
chmod g-w /usr/lib
chmod g-w /usr/lib/opencpn
chmod g-w /usr/lib/ossim
chmod g-w /usr/lib/ossim/plugins
chmod g-w /usr/share
chmod g-w /usr/share/opencpn -R
chmod g-w /usr/share/ossim/


# now that everything is installed rebuild library search cache
ldconfig


#shrink help page images
# echo "Shrinking images, please wait as this may take some time ..."

# cd /var/www/html/
# # instrument it to see if it's worth the effort (takes 2.25 minutes, saves <1mb)
# echo "`date`: /var/www/html takes `du -sm /var/www/html | cut -f1` mb"
# optipng -quiet -o5 `find | grep '\.png$' | grep -v './_images/'`
# echo "`date`: /var/www/html takes `du -sm /var/www/html | cut -f1` mb"
# cd -
#
# cd /usr/local/
# # takes 32 minutes, saves 5mb
# echo "`date`: /usr/local takes `du -sm /usr/local | cut -f1` mb"
# optipng -quiet -o5 `find | grep '\.png$' | grep -v gisvm`
# echo "`date`: /usr/local takes `du -sm /usr/local | cut -f1` mb"
# cd -
# maybe do this after fslint so that hardlink'd dupes get done too?


#### Check how much space is wasted by double files in /usr
# Checking which duplicate files are present can be useful to save
#  disk space manually.
# The actual hardlinking of duplicate /usr files is done at the last
#  minute in build_iso.sh.
# FSLINT_LOG=/tmp/build_lint/dupe_files.txt
# mkdir -p `dirname "$FSLINT_LOG"`
# echo "Scanning for duplicate files ..."
# /usr/share/fslint/fslint/findup --summary /usr /opt /lib > "$FSLINT_LOG"
# /usr/share/fslint/fslint/fstool/dupwaste < "$FSLINT_LOG"

## check how big the databases ended up
echo
echo "Postgres database sizes:"
sudo -u postgres psql << EOF
SELECT pg_database.datname,
       pg_size_pretty(pg_database_size(pg_database.datname)) AS size
  FROM pg_database;
EOF
echo

## run some tests to catch common installer mistakes
./tools/post_build_checks.sh


#### Copy tmp files, apt cache and logs ready for backup
mkdir "/tmp/$VERSION"
cd "/tmp/$VERSION"

mkdir "${VM}-tmp"
mv /tmp/build* "${VM}-tmp"
#mv /tmp/*downloads ${VM}-tmp

ln -s /var/log/osgeolive/ "${VM}-log"

#Copy the cache to tmp for backing up
cp -R /var/cache/apt/ "${VM}-apt-cache"


# srcpkgcache.bin can be dropped; not updating it all the time helps save
# space on persistent USBs. https://wiki.ubuntu.com/ReducingDiskFootprint
rm -f /var/cache/apt/srcpkgcache.bin
cat << EOF > /etc/apt/apt.conf.d/02nocache
Dir::Cache {
  srcpkgcache "";
}
EOF

# remove the apt-get cache
apt-get clean


echo "linux-image-generic install" | dpkg --set-selections

rm -fr \
  "$USER_HOME"/.bash_history \
  "$USER_HOME"/.ssh \
  "$USER_HOME"/.subversion \
  # /tmp/* \ # tmp is cleared during shutdown

  # Do we need the following:
  # "$USER_HOME"/.cache \
  # "$USER_HOME"/.config \
  # "$USER_HOME"/.dbus \


# clean out ssh keys which should be machine-unique
rm -f /etc/ssh/ssh_host_*_key*
# change a stupid sshd default
if [ -e /etc/ssh/sshd_config ] ; then
   sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
fi

# Start tomcat to ensure all applications are deployed
service tomcat7 start
sleep 120
service tomcat7 stop

# Disable auto-deploy to prevent applications to get removed after removing war files
# TODO: Add some note to wiki for users that want to deploy their own tomcat applications
sed -i -e 's/unpackWARs="true"/unpackWARs="false"/' -e 's/autoDeploy="true"/autoDeploy="false"/' \
    /etc/tomcat7/server.xml

#Cleaning up war files to save disk space
rm -f /var/lib/tomcat7/webapps/*.war

#Disabling default tomcat startup
update-rc.d -f tomcat7 remove

if [ ! -e /etc/sudoers.d/tomcat ] ; then
   cat << EOF > /etc/sudoers.d/tomcat
%users ALL=(root) NOPASSWD: /usr/sbin/service tomcat7 start,/usr/sbin/service tomcat7 stop,/usr/sbin/service tomcat7 status
EOF
fi
chmod 440 /etc/sudoers.d/tomcat

# Switching to default IPv6
rm /etc/gai.conf
mv /etc/gai.conf.orig /etc/gai.conf

# stop PostgreSQL and MySQL to avoid them thinking a crash happened next boot
service postgresql stop
service mysql stop


# This is done on an extra step after rebooting and tmp is cleared
#echo "==============================================================="
#echo " Compress image by wiping the virtual disk, filling empty space with zero."
#cat /dev/zero > zero.fill ; sync ; sleep 1 ; sync ; rm -f zero.fill


####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
