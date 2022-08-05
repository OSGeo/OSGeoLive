#!/bin/sh
#############################################################################
#
# Purpose: Creating OSGeoLive as an Ubuntu customization. In chroot part
#     https://help.ubuntu.com/community/LiveCDCustomization
# Author:  Stefan Hansen <shansen@lisasoft.com>
#	         Alex Mandel <tech_dev@wildintellect.com>
#	         Angelos Tzotsos <tzotsos@gmail.com>
#
#############################################################################
# Copyright (c) 2010-2022 Open Source Geospatial Foundation (OSGeo) and others.
# Copyright (c) 2009 LISAsoft
#
# Licensed under the GNU LGPL version >= 2.1.
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

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Wrong number of arguments"
    echo "Usage: inchroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: inchroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi
ARCH="$1"

if [ "$2" != "release" ] && [ "$2" != "nightly" ] ; then
    echo "Did not specify build mode, try using release or nightly as an argument"
    echo "Usage: inchroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi
BUILD_MODE="$2"

if [ "$#" -eq 4 ]; then
    GIT_BRANCH="$3"
    GIT_USER="$4"
elif [ "$#" -eq 3 ]; then
    GIT_BRANCH="$3"
    GIT_USER="OSGeo"
else
    GIT_BRANCH="master"
    GIT_USER="OSGeo"
fi

run_installer()
{
  SCRIPT=$1
  echo "===================================================================="
  echo "Starting: $SCRIPT"
  echo "===================================================================="
  sh "$SCRIPT"
}

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

# To avoid locale issues and in order to import GPG keys
export HOME=/roots
export LC_ALL=C

# In 9.10, before installing or upgrading packages you need to run
# TODO: Check/ask if this needs to be done in 12.04
dbus-uuidgen > /var/lib/dbus/machines-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# To view installed packages by size
# dpkg-query -W --showformat='${Installed-Size}\t${Package}\n' | sort -nr | less
# When you want to remove packages remember to use purge
# aptitude purge package-name

# Execute the osgeolive build
# Adding "user" to help the build process
adduser user --disabled-password --gecos user

# Change ID under 999 so that iso boot does not fail
# usermod -u 500 user
# TODO: Set the password for "user"
mkdir -p /home/user/Desktop
chown user:user /home/user/Desktop

# Fixing some IPv6 problems for the build server
mv /etc/gai.conf /etc/gai.conf.orig
cat << EOF > /etc/gai.conf
precedence ::ffff:0:0/96  100
EOF

cd /tmp/

chmod a+x bootstrap.sh

./bootstrap.sh "$GIT_BRANCH" "$GIT_USER"

cd /usr/local/share/gisvm/bin

# Copy external version information to be able to rename the builds
cp /tmp/VERSION.txt /usr/local/share/gisvm/
cp /tmp/CHANGES.txt /usr/local/share/gisvm/

#######################################################
# Replacement for main.sh
#######################################################
USER_NAME="user"
export USER_NAME

./setup.sh "$BUILD_MODE"

### Base installers
./base_c.sh
./base_python.sh
./base_java.sh
# ./base_language.sh

### Service installers
./service_apache2.sh
./base_php.sh
./service_tomcat.sh
./service_postgresql.sh
# ./service_mysql.sh

### Project installers
## C stack
./install_postgis.sh
./install_spatialite.sh
./install_osm.sh
./load_postgis.sh
./install_pgrouting.sh
./install_ossim.sh
./install_mapserver.sh
./install_mapcache.sh
./install_tinyows.sh
# ./install_gmt.sh # install_vm_only
./install_mapnik.sh
./install_otb.sh
./install_saga.sh
./install_grass.sh
./install_qgis.sh
./install_qgis_server.sh
./install_zoo-project.sh "$ARCH"
./install_marble.sh
./install_opencpn.sh
./install_xygrib.sh
./install_PDAL.sh

## Python stack
./install_mapproxy.sh
./install_pycsw.sh
./install_pywps.sh
./install_pygeoapi.sh
./install_eoxserver.sh
./install_istsos.sh
# ./install_actinia.sh # install_vm_only

## R stack
./install_R.sh

## Jupyter
./install_jupyter.sh

## Java stack
./install_geoserver.sh
./install_geonetwork.sh
./install_deegree.sh
# ./install_udig.sh "$ARCH" # install_vm_only
./install_openjump.sh
# ./install_gvsig.sh "$ARCH" # install_vm_only
./install_gpsprune.sh

## Java + default tomcat
./install_52nWPS.sh
# ./install_52nSOS.sh # install_vm_only
# ./install_ncWMS.sh # install_vm_only

## PHP stack
./install_mapbender.sh
./install_geomoose.sh

## more Python (GeoServer rdeps)
./install_geonode.sh

## Rust
./install_trex.sh

## Javascript et al
./install_openlayers.sh
./install_leaflet.sh
./install_cesium.sh
./install_geoext.sh
# ./install_rasdaman.sh # install_vm_only
./install_geostyler.sh
# ./install_re3gistry.sh # install_vm_only
# ./install_etf.sh # install_vm_only

## Docs, Data and extras
./load_gisdata.sh
./install_docs.sh "$BUILD_MODE"
# ./install_edutools.sh

## Desktop and Housekeeping
./install_desktop.sh
./install_icons_and_menus.sh
./setdown.sh


#######################################################
# End of main.sh
#######################################################

# Remove doc folder to save space
# rm -rf /usr/local/share/gisvm/doc

# Save space on ISO by removing the .git dir
NEAR_RC=1
if [ "$NEAR_RC" -eq 1 ] ; then
    rm -rf /usr/local/share/gisvm/.git
fi

# user shouldn't own outside of /home, but a group can
chown -R root.staff /usr/local/share/gisvm
chmod -R g+w /usr/local/share/gisvm

# Update the file search index
updatedb

# Experimental dist variant, comment out and swap to backup below
# Do we need to change the user to ubuntu in all scripts for this method?
# -- No, set user in casper.conf
tar -zcf /tmp/user_home.tar.gz -C /home/user .
tar -zxf /tmp/user_home.tar.gz -C /etc/skel .
rm /tmp/user_home.tar.gz
cp -a /home/user/*  /etc/skel
chown -hR root:root /etc/skel

# TODO: Should we remove the "user" after the installation?
# By keeping this user, /home/user exists and installation fails if someone uses the same username.
# killall -u user
# userdel -r user
deluser --remove-home user

# Copy casper.conf with default username and hostname
# FIXME: User is still "xubuntu" in live session... perhaps because user is already created?
cp /usr/local/share/gisvm/desktop-conf/casper/casper.conf /etc/casper.conf

# After the build
# Check for users above 999
awk -F: '$3 > 999' /etc/passwd

#### Cleanup ####

# Be sure to remove any temporary files which are no longer needed, as space on a CD is limited
apt-get clean

# Delete temporary files
rm -rf /tmp/* ~/.bash_history

# Delete hosts file
rm /etc/hosts

# Nameserver settings
rm /etc/resolv.conf
ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# If you installed software, be sure to run 
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

# Now umount (unmount) special filesystems and exit chroot 
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
