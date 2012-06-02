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
# Create menus and config automatic login.

# Running:
# =======
# sudo ./install_desktop.sh
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"
BUILD_DIR=`pwd`


################################################

#Desktop apps part 1 (traditional analytic GIS)
DESKTOP_APPS="grass qgis gvsig openjump uDig ossimplanet *Kosmo*
              spatialite-gis saga_gui atlasstyler geopublisher"

#Desktop apps part 2 (geodata viewers and editors)
NAV_APPS="marble gpsdrive opencpn josm gosmore merkaartor viking zygrib gpsprune"

#Server apps part 1 (web-enabled GIS; interactive/WPS)
WEB_SERVICES="deegree-* geoserver-* *geonetwork* mapserver mapproxy-*
              qgis-mapserver zoo-project 52n* mapguide* pycsw"

#Server apps part 2 (web based viewers; data only flows down to user)
BROWSER_CLIENTS="geomajas-* mapbender MapFish GeoMOOSE"

#Infrastructure and miscellanea
SPATIAL_TOOLS="imagelinker r geokettle openlayers
               maptiler mapnik-* monteverdi"

#Future home of PostGIS and Spatialite; pgRouting???
#  pgadmin, sqlitebrowser, etc  (this one is automatic)
DB_APPS="spatialite-gui *[Rr]asdaman*"

#Server apps part 3 (public good theme)
RELIEF_APPS="sahana ushahidi"

################################################


# Default password list on the desktop to be replaced by html help in the future.
cp ../doc/passwords.txt "$USER_HOME/Desktop/"
chown "$USER_NAME"."$USER_NAME" "$USER_HOME/Desktop/passwords.txt"


# Setup the desktop background image
cp ../desktop-conf/osgeo-desktop.png \
   /usr/share/xfce4/backdrops

#Done:support for headless installs with or without user existing, preference for png
#Only works if user is not logged into XFCE session
# Puts the desktop background into the spot where it would be used for new user creation
mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
cp ../desktop-conf/xfce/xfce4-desktop.xml \
     /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
#Copy it to the existing user
cp /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml \
     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
#Note: Style int 3 means stretched
#Not sure if this is necessary
chown "$USER_NAME"."$USER_NAME" "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"

#Old version in case we need to revert, or if you're logged into the current XFCE session
#Has to been run as the regular user
#sudo -u $USER_NAME xfconf-query -c xfce4-desktop \
#     -p /backdrop/screen0/monitor0/image-path \
#     -s /usr/share/xfce4/backdrops/osgeo-desktop.png
# set to stretch style background
#sudo -u $USER_NAME xfconf-query -c xfce4-desktop --create \
#     -p /backdrop/screen0/monitor0/image-style  -s 3  -t int



#Add the launchhelp script which allows other apps to provide sudo
#    launching with the password already embedded
#Geonetwork and deegree need this right now
cp "$USER_HOME/gisvm/bin/launchassist.sh" "$USER_HOME/"
chmod 755 "$USER_HOME/launchassist.sh"



# Ubuntu 9.10 (GNOME but not Xfce) wants to see the ~/Desktop/*.desktop
# files be executable, and start with this shebang: #!/usr/bin/env xdg-open
#  By this point all scripts should have run, if they haven't, too bad, they
#  should move to where they should be, earlier in the build process.
#-uncomment if needed for Xubuntu
##chmod u+x "$USER_HOME"/Desktop/*.desktop

### get list of *.desktop from bin/install_*.sh :
# grep '\.desktop' * | sed -e 's/\.desktop.*/.desktop/' -e 's+^.*[/" ]++' | sort | uniq


####################################
#### sort out the desktop icons ####
####################################
cd "$USER_HOME/Desktop"


##### create and populate the Geospatial menu, add launchers to the panel

## OSGeo menu and CPU load for top taskbar:

if [ `grep -c 'value="Geospatial"' /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml` -eq 0 ] ; then
  #present full applications menu name
    sed -i -e 's+\(name="show-button-title" type="bool"\) value="false"/>+\1 value="true"/>\n      <property name="button-title" type="string" value="Applications"/>+' \
      /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml

  #add new things to the top menubar
  sed -i -e 's+\(<value type="int" value="1"/>\)+\1\n\t<value type="int" value="360"/>\n\t<value type="int" value="365"/>+' \
         -e 's+<value type="int" value="6"/>+<value type="int" value="362"/>+' \
	 -e 's+\(<value type="int" value=\)"26"/>+\1"363"/>\n        \1"26"/>+' \
	 -e 's+^\(  </property>\)+    <property name="plugin-365" type="string" value="separator">\n      <property name="style" type="uint" value="3"/>\n    </property>\n    <property name="plugin-360" type="string" value="applicationsmenu">\n      <property name="custom-menu" type="bool" value="true"/>\n      <property name="custom-menu-file" type="string" value="/usr/local/share/xfce/xfce-osgeo.menu"/>\n      <property name="button-icon" type="string" value="gnome-globe"/>\n      <property name="button-title" type="string" value="Geospatial"/>\n    </property>\n    <property name="plugin-362" type="string" value="cpugraph"/>\n    <property name="plugin-363" type="string" value="xkb-plugin"/>\n\1+' \
	    /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml
fi

if [ -e "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" ] ; then
  cp -f /etc/xdg/xdg-xubuntu/xfce4/panel/default.xml \
     "$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
fi

cp "$BUILD_DIR"/../desktop-conf/xfce/cpugraph-362.rc /etc/xdg/xdg-xubuntu/xfce4/panel/
cp "$BUILD_DIR"/../desktop-conf/xfce/xkb-plugin-363.rc /etc/xdg/xdg-xubuntu/xfce4/panel/

# two workspaces
sed -i -e 's+\("workspace_count" type="int" value=\)"1"+\1"2"+' \
   /usr/share/xubuntu/xdg-gdm/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
# on the ISO version the home dir has already been populated:
USER_PANEL_CONF="$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
if [ -e "$USER_PANEL_CONF" ] ; then
   sed -i -e 's+\("workspace_count" type="int" value=\)"1"+\1"2"+' "$USER_PANEL_CONF"
fi


mkdir -p /usr/local/share/xfce
mkdir -p /usr/local/share/applications


# pared down copy of /etc/xdg/xdg-xubuntu/menus/xfce-applications.menu
cp "$BUILD_DIR"/../desktop-conf/xfce/xfce-osgeo.menu /usr/local/share/xfce/
cp "$BUILD_DIR"/../desktop-conf/xfce/xfce-*.directory /usr/share/desktop-directories/
sed -e 's/^Name=.*/Name=OSGeo Software Help/' live_GIS_help.desktop \
   > /usr/local/share/applications/osgeo-help.desktop


# if you want panel transparency turned on edit Apps->Settings->WM Tweaks or
#  /etc/xdg/xdg-xubuntu/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#         ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
#    <property name="use_compositing" type="bool" value="true"/>


# create individual menu entries from desktop icons:
for APP in $DESKTOP_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Desktop GIS;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"
   fi
done

for APP in $NAV_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Navigation;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"

      case "$APP" in
	 josm | merkaartor | gosmore) GROUP=OpenStreetMap;;
	 *) unset GROUP;;
      esac
      if [ -n "$GROUP" ] ; then
         sed -i -e "s/^\(Categories=.*\)/\1$GROUP;/" \
             "/usr/local/share/applications/osgeo-$APPL"
      fi
   fi
done

for APP in $WEB_SERVICES ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Geoservers;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"

      case "$APPL" in
        geoserver-*) GROUP=GeoServer;;
        *geonetwork*) GROUP=GeoNetwork;;
        mapproxy-*) GROUP=MapProxy;;
        52n*) GROUP=52North;;
        deegree-*) GROUP=deegree;;
        *) unset GROUP;;
      esac
      if [ -n "$GROUP" ] ; then
         sed -i -e "s/^\(Categories=.*\)/\1$GROUP;/" \
             "/usr/local/share/applications/osgeo-$APPL"
      fi
   fi
done

for APP in $BROWSER_CLIENTS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Geoclients;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"
   fi
done

for APP in $SPATIAL_TOOLS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Spatial Tools;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"
   fi
done

for APP in $DB_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Database;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"

      case "$APPL" in
	*asdaman*) GROUP=Rasdaman;;
        *) unset GROUP;;
      esac
      if [ -n "$GROUP" ] ; then
         sed -i -e "s/^\(Categories=.*\)/\1$GROUP;/" \
             "/usr/local/share/applications/osgeo-$APPL"
      fi
   fi
done

for APP in $RELIEF_APPS ; do
   APPL=`basename $APP .desktop`.desktop
   #echo "[$APP] -> [$APPL]"
   if [ -e "$APPL" ] ; then
      sed -e 's/^Categories=.*/Categories=Geospatial;Relief;/' \
	 "$APPL" > "/usr/local/share/applications/osgeo-$APPL"
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

mkdir "Web Services"
for APP in $WEB_SERVICES ; do
   mv `basename $APP .desktop`.desktop "Web Services"/
done

mkdir "Browser Clients"
for APP in $BROWSER_CLIENTS ; do
   mv `basename $APP .desktop`.desktop "Browser Clients"/
done

mkdir "Spatial Tools"
for APP in $SPATIAL_TOOLS ; do
   mv `basename $APP .desktop`.desktop "Spatial Tools"/
done

mkdir "Crisis Management"
for APP in $RELIEF_APPS ; do
   mv `basename $APP .desktop`.desktop "Crisis Management"/
done

# admin tools already added automatically to the menu ...
mkdir "Databases"
for APP in $DB_APPS ; do
   mv `basename $APP .desktop`.desktop "Databases"/
done
# ... but need to be manually copied into the desktop folders
for ITEM in sqlitebrowser pgadmin3 MySQLAdministrator ; do
   cp "/usr/share/applications/$ITEM.desktop" "Databases"/
done


### web-services sub menu infrastructure
mkdir -p /etc/xdg/menus/applications-merged/

APP_GROUPS="GeoServer GeoNetwork MapProxy 52North deegree Rasdaman"

for APP in $APP_GROUPS ; do
   cat << EOF > "/etc/xdg/menus/applications-merged/$APP.menu"
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
<Name>Applications</Name>
  <Menu>
  <Name>Geoservers</Name>
    <Menu>
    <Name>$APP</Name>
    <Directory>$APP.directory</Directory>
    <Include>
    <Category>$APP</Category>
    </Include>
    </Menu>
  </Menu> 
</Menu> 
EOF

   case "$APP" in
     GeoServer) APP_ICON=/usr/share/icons/geoserver_48x48.logo.png;;
     GeoNetwork) APP_ICON=/usr/lib/geonetwork/bin/ico/gn.ico;;
     MapProxy) APP_ICON=gnome-globe;;
     52North) APP_ICON=/usr/share/icons/52n.png;;
     deegree) APP_ICON=/usr/share/icons/deegree_desktop_48x48.png;;
     Rasdaman) APP_ICON=gnome-globe;;
     *) unset APP_ICON;;
   esac

   cat << EOF > "/usr/share/desktop-directories/$APP.directory"
[Desktop Entry]
Encoding=UTF-8
Type=Directory
Comment=
Icon=$APP_ICON
Name=$APP
EOF

done

#### OpenStreetMap submenu
APP=OpenStreetMap
cat << EOF > "/etc/xdg/menus/applications-merged/$APP.menu"
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
<Name>Applications</Name>
  <Menu>
  <Name>Navigation and Maps</Name>
    <Menu>
    <Name>$APP</Name>
    <Directory>$APP.directory</Directory>
    <Include>
    <Category>$APP</Category>
    </Include>
    </Menu>
  </Menu> 
</Menu> 
EOF

APP_ICON=josm-32

cat << EOF > "/usr/share/desktop-directories/$APP.directory"
[Desktop Entry]
Encoding=UTF-8
Type=Directory
Comment=
Icon=$APP_ICON
Name=$APP
EOF



##### Setup Automatic or Timed Login #####
cp "$BUILD_DIR"/../desktop-conf/custom.conf /etc/gdm/custom.conf



##### Setup timed welcome message
mkdir -p /usr/local/share/osgeo-desktop

cat << EOF > "/usr/local/share/osgeo-desktop/welcome_message.desktop"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Welcome message
Comment=Live Demo welcome message
Exec=/usr/local/share/osgeo-desktop/welcome_message.sh
Terminal=false
StartupNotify=false
Hidden=false
EOF

mkdir -p "$USER_HOME"/.config/autostart
cp /usr/local/share/osgeo-desktop/welcome_message.desktop \
   "$USER_HOME"/.config/autostart/

cp "$BUILD_DIR/../desktop-conf/welcome_message.sh" \
   /usr/local/share/osgeo-desktop/

#
# LANG_CODE is defined in main.sh
#
#cp "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.* \
#   /usr/local/share/osgeo-desktop/

if [ -e "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.txt ] ; then
  cp "$BUILD_DIR/../doc/$LANG_CODE"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
else
  cp "$BUILD_DIR/../doc/en"/welcome_message.txt \
    /usr/local/share/osgeo-desktop/
fi

cp /usr/local/share/osgeo-desktop/welcome_message.txt "$USER_HOME"/
chown "$USER_NAME"."$USER_NAME" "$USER_HOME"/welcome_message.txt


##### Setup workshop installation icon
WORKSHOP_INSTALL_FILE="workshop_installation.desktop"
cat << EOF > "/usr/share/applications/$WORKSHOP_INSTALL_FILE"
[Desktop Entry]
Name=Workshop Installation
Comment=Installation for OSGeo-live based workshops
Exec=firefox http://trac.osgeo.org/osgeo/wiki/Live_GIS_Workshop_Install
Icon=softwarecenter
Terminal=false
Type=Application
Categories=Application;Education;Geography;
StartupNotify=true
EOF

\cp -a "/usr/share/applications/$WORKSHOP_INSTALL_FILE" "$USER_HOME/Desktop/"
chown $USER_NAME.$USER_NAME "$USER_HOME/Desktop/$WORKSHOP_INSTALL_FILE"


#### permissions cleanup (if needed)
chown "$USER_NAME"."$USER_NAME" "$USER_HOME/Desktop/" -R
chmod a+r "$USER_HOME/Desktop/" -R


#### FOSS the Software Center
cd /usr/share/software-center/
patch -p0 -N -r - --quiet < "$BUILD_DIR/../desktop-conf/FOSScenter.patch"
PYCs=`grep ORIG FOSScenter.patch | sed -e 's/\.ORIG.*//' -e 's/.[^\.]*//' -e 's/$/c/'`
rm -f $PYCs
#fixme:  pycompile -p ... ?? (running software-center as root will rebuild them)
rm -rf "$USER/.cache/software-center/"


#### replace the Software Center on the Apps menu with the more useful Synaptic
# .. TODO   (right click the Apps menu, properties, edit, add synaptic-pkexec, 
#       name it package manager to keep the width narrow; then create a patch)
#  Maybe leave the lower app bar as software-center so users can still get to
#       it if they want to.


#### the default xUbuntu 12.04 theme has 1px wide window borders which
# makes it extremely tricky to resize them. tweak the theme so that
# window borders are 4px wide so they are easier to grab.
cp -f "$BUILD_DIR"/../desktop-conf/xfce/greybird_theme/*.xpm \
   /usr/share/themes/Greybird/xfwm4/


