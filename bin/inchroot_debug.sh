#!/bin/sh
#################################################
# 
# Purpose: Creating OSGeoLive as an Ubuntu customization. In chroot part
# 	   https://help.ubuntu.com/community/LiveCDCustomization
# Author:  Stefan Hansen <shansen@lisasoft.com>
#	   Alex Mandel <tech_dev@wildintellect.com>
#	   Angelos Tzotsos <tzotsos@gmail.com>
#
#################################################
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
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
##################################################

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

#To avoid locale issues and in order to import GPG keys 
export HOME=/roots
export LC_ALL=C

#In 9.10, before installing or upgrading packages you need to run
#TODO: Check/ask if this needs to be done in 12.04
dbus-uuidgen > /var/lib/dbus/machines-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

#To view installed packages by size
#dpkg-query -W --showformat='${Installed-Size}\t${Package}\n' | sort -nr | less
#When you want to remove packages remember to use purge 
#aptitude purge package-name

#Execute the osgeolive build
#Adding "user" to help the build process
adduser user --disabled-password --gecos user
#change ID under 999 so that iso boot does not fail
#usermod -u 500 user
#TODO Set the password for "user"
mkdir -p /home/user/Desktop
chown user:user /home/user/Desktop

cd /tmp/
wget https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/bin/bootstrap.sh
chmod a+x bootstrap.sh
./bootstrap.sh
cd /usr/local/share/gisvm/bin
#copy external version information to be able to rename the builds
cp /tmp/VERSION.txt /usr/local/share/gisvm/
cp /tmp/CHANGES.txt /usr/local/share/gisvm/
#Redirecting to main_install.log does not allow main.sh to exit properly
#./main.sh 2>&1 | tee /var/log/osgeolive/main_install.log
#./main.sh
USER_NAME="user"
export USER_NAME
./setup.sh
./install_services.sh
./install_mysql.sh
./install_java.sh
./install_apache2.sh
./install_tomcat6.sh

# ./install_geoserver.sh
# ./install_geomajas.sh
# ./install_geonetwork.sh
# ./install_deegree.sh
# ./install_52nWPS.sh
# ./install_kosmo.sh
# ./install_udig.sh
# ./install_openjump.sh
# ./install_postgis.sh
# ./install_osm.sh
# ./load_postgis.sh
# ./install_pgrouting.sh
# ./install_sahana.sh
# ./install_ushahidi.sh
# ./install_mapserver.sh
# ./install_mapbender.sh
# ./install_geokettle.sh
# ./install_gmt.sh
# ./install_grass.sh
# ./install_qgis.sh
# ./install_qgis_mapserver.sh
# ./install_saga.sh
# ./install_mapnik.sh
# ./install_mapproxy.sh
# ./install_maptiler.sh
# ./install_marble.sh
# ./install_opencpn.sh
# ./install_prune.sh
# ./install_viking.sh
# ./install_zygrib.sh
# ./install_geopublisher.sh
# ./install_atlasstyler.sh
# ./install_liblas.sh
# ./install_gpsdrive.sh
# ./install_mapfish.sh
# ./install_openlayers.sh
# ./install_R.sh
# ./install_ossim.sh
# ./install_osgearth.sh
# ./install_spatialite.sh
# ./install_zoo-project.sh
# ./install_52nSOS.sh
# ./install_otb.sh
# ./install_rasdaman.sh
# ./install_tinyows.sh
# ./install_52nWSS.sh
# ./install_pycsw.sh
# ./install_geomoose.sh
# ./install_mb-system.sh
# ./install_gvsig.sh

# ./load_gisdata.sh
# ./install_main_docs.sh
# ./install_edutools.sh

./install_desktop.sh
./install_language.sh
./setdown.sh


#Remove doc folder to save space
rm -rf /usr/local/share/gisvm/doc

# save space on ISO by removing the .svn/ dirs
#   (or control this in bootstrap.sh by uncommenting the 'svn export' line)
for DIR in `find /usr/local/share/gisvm | grep '\.svn$'` ; do
   rm -rf "$DIR"
done

# Update the file search index
#updatedb

#Experimental dist variant, comment out and swap to backup below
#Do we need to change the user to ubuntu in all scripts for this method? No set user in casper.conf
tar -zcf /tmp/user_home.tar.gz -C /home/user .
tar -zxf /tmp/user_home.tar.gz -C /etc/skel .
rm /tmp/user_home.tar.gz
cp -a /home/user/*  /etc/skel
chown -hR root:root /etc/skel

#TODO: Should we remove the "user" after the installation? 
#By keeping this user, /home/user exists and installation fails if someone uses the same username.
#killall -u user
#userdel -r user
deluser --remove-home user

#Copy casper.conf with default username and hostname
#FIXME: User is still "xubuntu" in live session... perhaps because user is already created?
cp /usr/local/share/gisvm/app-conf/casper.conf /etc/casper.conf

#After the build
#Check for users above 999
awk -F: '$3 > 999' /etc/passwd

#Cleanup
#Be sure to remove any temporary files which are no longer needed, as space on a CD is limited
apt-get clean
#Or delete temporary files
rm -rf /tmp/* ~/.bash_history
#Or delete hosts file 
rm /etc/hosts
#Or nameserver settings 
rm /etc/resolv.conf
#If you installed software, be sure to run 
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
#now umount (unmount) special filesystems and exit chroot 
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
