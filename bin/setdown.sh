#!/bin/sh
#############################################################################
#
# Purpose: This script will cleanup the system after running OSGeoLive
# install scripts.
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

# Add 'user' to needed groups
#   GRPS="audio dialout fuse plugdev pulse staff tomcat7 users www-data vboxsf"
#bad smelling hack to mitigate the effects of #1104's race condition
GRPS="users tomcat www-data staff plugdev audio dialout pulse vboxsf"

## Create systemd service for manage_user_groups.sh
## source: https://askubuntu.com/questions/814/how-to-run-scripts-on-start-up/719157#719157

if [ ! -e /etc/systemd/system/manage_user_groups.service ] ; then
    cat << EOF > /etc/systemd/system/manage_user_groups.service
[Unit]
Description=Add user to needed groups

[Service]
ExecStart=/usr/sbin/adduser $USER_NAME users
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
fi

# for GRP in $GRPS ; do
#   echo "ExecStart=/usr/sbin/adduser $USER_NAME $GRP" >> /etc/systemd/system/manage_user_groups.service
# done

## reload systemctl config
systemctl daemon-reload

## Start service to add user to groups
systemctl start manage_user_groups.service

## Enable manage_user_groups service at startup
systemctl enable manage_user_groups.service

# Re-enable if user does not belong to groups
# cp ../desktop-conf/casper/27osgeo_groups \
#   /usr/share/initramfs-tools/scripts/casper-bottom/

# remove build stuff no longer of use
apt-get --yes remove libboost1.74-dev gcc-11 g++-11 gfortran-11 build-essential

# remove stuff to save disk space (#467)
apt-get --yes remove libreoffice-common libreoffice-core 2048-qt noblenote trojita \
  transmission-common k3b vlc snapd fonts-noto-cjk

# remove any leftover orphans
apt-get --yes autoremove

# remove linux headers
apt-get --yes remove linux-headers-generic
apt-get --yes remove linux-headers-5.15.0-25

# Python packages disk space cleanup
rm -rf /usr/lib/python3/dist-packages/pandas/tests/*
rm -rf /usr/lib/python3/dist-packages/simplejson/tests/*
rm -rf /usr/lib/python3/dist-packages/seaborn/tests/*
rm -rf /usr/lib/python3/dist-packages/scipy/special/tests/*
rm -rf /usr/lib/python3/dist-packages/scipy/optimize/tests/*
rm -rf /usr/lib/python3/dist-packages/scipy/io/tests/*
rm -rf /usr/lib/python3/dist-packages/scipy/io/matlab/tests/*
rm -rf /usr/lib/python3/dist-packages/matplotlib/tests/*
rm -rf /usr/lib/python3/dist-packages/numpy/core/tests/*
rm -rf /usr/lib/python3/dist-packages/numpy/lib/tests/*
rm -rf /usr/lib/python3/dist-packages/numpy/ma/tests/*
rm -rf /usr/lib/python3/dist-packages/numpy/polynomial/tests/*
rm -rf /usr/lib/python3/dist-packages/numpy/tests/*

cd /usr/lib/python3/dist-packages;
## ----------------------------------------
## clear out more test dirs manually..
rm -rf cartopy/tests/*
rm -rf iris/tests/*
rm -rf mpl_toolkits/tests/*
rm -rf scipy/stats/tests/*
rm -rf mapproxy/test/*
rm -rf scipy/spatial/tests/*
rm -rf samba/tests/*
rm -rf tornado/test/*
rm -rf scipy/linalg/tests/*
rm -rf scipy/signal/tests/*
rm -rf psycopg2/tests/*
rm -rf dask/dataframe/tests/*
rm -rf dask/array/tests/*
rm -rf sqlalchemy/testing/*
rm -rf networkx/classes/tests/*
rm -rf scipy/interpolate/tests/*
rm -rf scipy/ndimage/tests/*
rm -rf biggus/tests/*
rm -rf scipy/sparse/tests/*
rm -rf scipy/fftpack/tests/*
rm -rf mock/tests/*
#rm -rf numpy/testing/*  ## numpy will not start w/o tests
rm -rf zmq/tests/*
rm -rf networkx/algorithms/tests/*
rm -rf dask/tests/*
#rm -rf django/test/*   ## geonode will not work without test/utils.py
rm -rf dask/dataframe/io/tests/*
rm -rf networkx/algorithms/flow/tests/*
#rm -rf IPython/testing/*  ## ipython fails to start if rm'd
rm -rf geopandas/tests/*
rm -rf jupyter_core/tests/*
rm -rf pbr/tests/*
rm -rf matplotlib/testing/*
rm -rf networkx/algorithms/shortest_paths/*
rm -rf traitlets/tests/*
rm -rf future/backports/test/*
rm -rf toolz/tests/*
##---------------------------------------


# some tarball or something is making /usr group writable, which
#  makes openssh-server refuse to start.  (FIXME)
#/usr/lib/Kosmo-3.0/
chmod g-w /usr
chmod g-w /usr/bin
chmod g-w /usr/lib
chmod g-w /usr/lib/opencpn
# chmod g-w /usr/lib/ossim
# chmod g-w /usr/lib/ossim/plugins
chmod g-w /usr/share
chmod g-w /usr/share/opencpn -R
chmod g-w /usr/share/ossim/


# now that everything is installed rebuild library search cache
ldconfig

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
cd "$BUILD_DIR"
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

# This might be needed in the future when more kernels get included in .x releases
# echo "linux-image-generic-hwe-16.04 install" | dpkg --set-selections

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
# FIXME: systemctl and service are not available in chroot.
# service tomcat9 start
# sleep 120
# service tomcat9 stop

# Disable auto-deploy to prevent applications to get removed after removing war files
# TODO: Add some note to wiki for users that want to deploy their own tomcat applications
# sed -i -e 's/unpackWARs="true"/unpackWARs="false"/' -e 's/autoDeploy="true"/autoDeploy="false"/' \
    # /etc/tomcat9/server.xml

# Cleaning up war files to save disk space
# rm -f /var/lib/tomcat9/webapps/*.war

# Disabling default tomcat startup
#update-rc.d -f tomcat7 remove
systemctl disable tomcat9.service
# systemctl disable rasdaman.service
systemctl disable redis.service

if [ ! -e /etc/sudoers.d/tomcat ] ; then
   cat << EOF > /etc/sudoers.d/tomcat
%user ALL=(root) NOPASSWD: /usr/sbin/service tomcat9 start,/usr/sbin/service tomcat9 stop,/usr/sbin/service tomcat9 status
EOF
fi
chmod 440 /etc/sudoers.d/tomcat

# #2084: Fix home path for exracted ncWMS
# sed -i -e 's|\$HOME/.ncWMS2|/usr/share/tomcat9/.ncWMS2|' /var/lib/tomcat9/webapps/ncWMS2/WEB-INF/web.xml

# #2263: Fix installation of live system
sed -i -e 's|/home/lubuntu|/home/user|' /bin/calamares-logs-helper

# Switching to default IPv6
rm /etc/gai.conf
mv /etc/gai.conf.orig /etc/gai.conf

# stop PostgreSQL and MySQL to avoid them thinking a crash happened next boot
service postgresql stop
service apache2 stop
# service mysql stop

# This is done on an extra step after rebooting and tmp is cleared
#echo "==============================================================="
#echo " Compress image by wiping the virtual disk, filling empty space with zero."
#cat /dev/zero > zero.fill ; sync ; sleep 1 ; sync ; rm -f zero.fill

# Deleting users created by tomcat installer in chroot.
# Hopefully they will be created on boot time by /usr/lib/sysusers.d/tomcat9.conf
# deluser tomcat
# deluser systemd-coredump

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
