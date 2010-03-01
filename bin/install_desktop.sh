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
# This script will install a desktop background image and icon for passwords.

# Running:
# =======
# sudo ./install_desktop.sh
USER_NAME=user
USER_HOME=/home/$USER_NAME

# Default password list on the desktop to be replaced by html help in the future.
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/passwords.txt \
    --output-document="$USER_HOME/Desktop/passwords.txt"
chown user:user "$USER_HOME/Desktop/passwords.txt"

# Setup the desktop background
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/desktop-conf/background.jpg \
    --output-document=/usr/share/xfce4/backdrops/osgeo-desktop.jpg

#TODO:copy over default image file instead for headless installs, preference for png
#Has to been run as the regular user
sudo -u $USER_NAME xfconf-query -c xfce4-desktop \
     -p /backdrop/screen0/monitor0/image-path \
     -s /usr/share/xfce4/backdrops/osgeo-desktop.jpg
# set to stretch style background
sudo -u $USER_NAME xfconf-query -c xfce4-desktop --create \
     -p /backdrop/screen0/monitor0/image-style  -s 3  -t int



#Add the launchhelp script which allows other apps to provide sudo launching with the password already embedded
#Geonetwork and deegree needs this right now
cp "$USER_HOME/gisvm/bin/launchassist.sh" "$USER_HOME/"
chmod 755 "$USER_HOME/launchassist.sh"


# Ubuntu 9.10 (GNOME) wants to see the ~/Desktop/*.desktop files be executable,
# and start with this shebang: #!/usr/bin/env xdg-open
#  By this point all scripts should have run, if they haven't, too bad, they
#  should move to where they should be, earlier in the build process.
#-uncomment if needed for Xubuntu
##chmod u+x "$USER_HOME"/Desktop/*.desktop


#### attempt to clean up the desktop icons
# (putting everything in a menu tree should happen too, but these things are not
# mutually exclusive)
cd "$USER_HOME/Desktop"

mkdir "Desktop GIS"
DESKTOP_APPS="grass qgis gvsig openjump uDig ossimplanet Kosmo_2.0_RC1"
for APP in $DESKTOP_APPS ; do
   mv "$APP.desktop" "Desktop GIS"/
done

mkdir "Navigation and Maps"
NAV_APPS="MapFish marble gpsdrive opencpn mapnik-*"
for APP in $DESKTOP_APPS ; do
   mv $APP.desktop "Navigation and Maps"/
done

mkdir "Server"  # what to call this?
NAV_APPS="deegree-* geoserver-* *geonetwork geomajas-* mapserver"
for APP in $DESKTOP_APPS ; do
   mv $APP.desktop "Server"/
done


mkdir "Geo Tools"  # what to call this?
NAV_APPS="maptiler imagelinker r spatialite-*"
for APP in $DESKTOP_APPS ; do
   mv $APP.desktop "Geo Tools"/
done


### get list of *.desktop from bin/install_*.sh :
# grep '\.desktop' * | sed -e 's/\.desktop.*/.desktop/' -e 's+^.*[/" ]++' | sort | uniq
#
#List as of 1 March 2010:
#
# deegree-start.desktop
# deegree-stop.desktop
# geokettle.desktop
# geomajas-start.desktop
# geomajas-stop.desktop
# geonetwork.desktop
# geoserver-admin.desktop
# geoserver-docs.desktop
# geoserver-start.desktop
# geoserver-stop.desktop
# geoserver-styler.desktop
# gpsdrive.desktop
# grass.desktop
# gvsig.desktop
# imagelinker.desktop
# Kosmo_2.0_RC1.desktop
# [live_GIS_help.desktop]  leave on main desktop
# MapFish.desktop
# mapnik-intro.desktop
# mapnik-start.desktop
# mapserver.desktop
# maptiler.desktop
# opencpn.desktop
# openjump.desktop
# ossimplanet.desktop
# qgis.desktop
# r.desktop
# spatialite-gis.desktop
# spatialite-gui.desktop
# start_geonetwork.desktop
# stop_geonetwork.desktop
# [ubiquity-gtkui.desktop]  rename in possible
# uDig.desktop
# 


# permissions cleanup (if needed)
chown user:user "$USER_HOME/Desktop/" -R
chmod a+r "$USER_HOME/Desktop/" -R
