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
# This script will install a desktop background image and icon for passwords. Create menus and config automatic login.

# Running:
# =======
# sudo ./install_desktop.sh
USER_NAME="user"
USER_HOME="/home/$USER_NAME"

BUILD_DIR=`pwd`

# Default password list on the desktop to be replaced by html help in the future.
wget -nv https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/doc/passwords.txt \
    --output-document="$USER_HOME/Desktop/passwords.txt"
chown user:user "$USER_HOME/Desktop/passwords.txt"

# Setup the desktop background
cp ../desktop-conf/blue-wombat.png \
     /usr/share/xfce4/backdrops/osgeo-desktop.png

#TODO:copy over default image file instead for headless installs, preference for png
#Has to been run as the regular user
sudo -u $USER_NAME xfconf-query -c xfce4-desktop \
     -p /backdrop/screen0/monitor0/image-path \
     -s /usr/share/xfce4/backdrops/osgeo-desktop.png
# set to stretch style background
sudo -u $USER_NAME xfconf-query -c xfce4-desktop --create \
     -p /backdrop/screen0/monitor0/image-style  -s 3  -t int



#Add the launchhelp script which allows other apps to provide sudo
#    launching with the password already embedded
#Geonetwork and deegree needs this right now
cp "$USER_HOME/gisvm/bin/launchassist.sh" "$USER_HOME/"
chmod 755 "$USER_HOME/launchassist.sh"



# Ubuntu 9.10 (GNOME but not Xfce) wants to see the ~/Desktop/*.desktop
# files be executable, and start with this shebang: #!/usr/bin/env xdg-open
#  By this point all scripts should have run, if they haven't, too bad, they
#  should move to where they should be, earlier in the build process.
#-uncomment if needed for Xubuntu
##chmod u+x "$USER_HOME"/Desktop/*.desktop


#### attempt to clean up the desktop icons
cd "$USER_HOME/Desktop"

### get list of *.desktop from bin/install_*.sh :
# grep '\.desktop' * | sed -e 's/\.desktop.*/.desktop/' -e 's+^.*[/" ]++' | sort | uniq

DESKTOP_APPS="grass qgis gvsig openjump uDig ossimplanet Kosmo_2.0_RC1 spatialite-gis"
NAV_APPS="MapFish marble gpsdrive opencpn mapnik-* josm gosmore"
SERVER_APPS="deegree-* geoserver-* *geonetwork* geomajas-* mapserver"
SPATIAL_TOOLS="maptiler imagelinker r spatialite-gui geokettle"
DB_APPS=""  # pgadmin, sqlitebrowser, etc

##### create and populate the Geospatial menu, add launchers to the panel

mkdir /usr/local/share/xfce
# OSGeo menu, Terminal launcher, and CPU load for top taskbar:
cp "$BUILD_DIR"/../desktop-conf/xfce/xfce4-menu-360.rc /etc/xdg/xubuntu/xfce4/panel/
cp "$BUILD_DIR"/../desktop-conf/xfce/launcher-361.rc /etc/xdg/xubuntu/xfce4/panel/
cp "$BUILD_DIR"/../desktop-conf/xfce/cpugraph-362.rc /etc/xdg/xubuntu/xfce4/panel/

# also modify user account's version, if it exists
USER_PANEL="$USER_HOME/.config/xfce4/panel"
if [ -d "$USER_PANEL" ] ; then
   cp "$BUILD_DIR"/../desktop-conf/xfce/xfce4-menu-360.rc "$USER_PANEL"
   cp "$BUILD_DIR"/../desktop-conf/xfce/launcher-361.rc "$USER_PANEL"
   cp "$BUILD_DIR"/../desktop-conf/xfce/cpugraph-362.rc "$USER_PANEL"
fi

# edit the panel to add these things
## .. if it hasn't already been done
if [ `grep -c 'xfce4-menu" id="360"' /etc/xdg/xubuntu/xfce4/panel/panels.xml` -eq 0 ] ; then
   sed -i -e 's+\(xfce4-menu.*\)+\1\n\t\t\t<item name="xfce4-menu" id="360"/>+' \
      -e 's+\(launcher" id="3".*\)+\1\n\t\t\t<item name="launcher" id="361"/>+' \
      -e 's+\(.*item name="clock"\)+\t\t\t<item name="cpugraph" id="362"/>\n\1+' \
      /etc/xdg/xubuntu/xfce4/panel/panels.xml
fi
# also modify user account's version, if it exists
if [ -e "$USER_PANEL/panels.xml" ] ; then
   if [ `grep -c 'xfce4-menu" id="360"' "$USER_PANEL/panels.xml"` -eq 0 ] ; then
      sed -i -e 's+\(xfce4-menu.*\)+\1\n\t\t\t<item name="xfce4-menu" id="360"/>+' \
         -e 's+\(launcher" id="3".*\)+\1\n\t\t\t<item name="launcher" id="361"/>+' \
         -e 's+\(.*item name="clock"\)+\t\t\t<item name="cpugraph" id="362"/>\n\1+' \
         "$USER_PANEL/panels.xml"
   fi
fi

# pared down copy of /etc/xdg/xubuntu/menus/xfce-applications.menu
cp "$BUILD_DIR"/../desktop-conf/xfce/xfce-osgeo.menu /usr/local/share/xfce/
cp "$BUILD_DIR"/../desktop-conf/xfce/xfce-*.directory /usr/share/desktop-directories/
sed -e 's/^Name=.*/Name=OSGeo Software Help/' live_GIS_help.desktop \
   > /usr/share/applications/osgeo-help.desktop


# if you want panel transparency turned on edit Apps->Settings->WM Tweaks or
#  /etc/xdg/xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#         ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#    <property name="use_compositing" type="bool" value="true"/>


# create individual menu entries from desktop icons:
for APP in $DESKTOP_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Desktop GIS;/' \
	 "$APPL" > "/usr/share/applications/osgeo-$APPL"
   fi
done

for APP in $NAV_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Navigation;/' \
	 "$APPL" > "/usr/share/applications/osgeo-$APPL"
   fi
done

for APP in $SERVER_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Geoservers;/' \
	 "$APPL" > "/usr/share/applications/osgeo-$APPL"
   fi
done

for APP in $SPATIAL_TOOLS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Spatial Tools;/' \
	 "$APPL" > "/usr/share/applications/osgeo-$APPL"
   fi
done

for APP in $DB_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Database;/' \
	 "$APPL" > "/usr/share/applications/osgeo-$APPL"
   fi
done



#### move desktop icons to subfolders
mkdir "Desktop GIS"
for APP in $DESKTOP_APPS ; do
   mv `basename $APP .desktop`.desktop "Desktop GIS"/
done

mkdir "Navigation and Maps"
for APP in $NAV_APPS ; do
   mv `basename $APP .desktop`.desktop "Navigation and Maps"/
done

mkdir "Servers"
for APP in $SERVER_APPS ; do
   mv `basename $APP .desktop`.desktop "Servers"/
done

mkdir "Spatial Tools"
for APP in $SPATIAL_TOOLS ; do
   mv `basename $APP .desktop`.desktop "Spatial Tools"/
done

#todo
#mkdir "Databases"
#for APP in $DB_APPS ; do
#   mv `basename $APP .desktop`.desktop "Databases"/
#done

####### Setup Automatic or Timed Login #####
cp "$BUILD_DIR"/../desktop-conf/custom.conf /etc/gdm/custom.conf

#### permissions cleanup (if needed)
chown user:user "$USER_HOME/Desktop/" -R
chmod a+r "$USER_HOME/Desktop/" -R
