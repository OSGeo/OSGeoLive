#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Copyright (c) 2009 LISAsoft
# Copyright (c) 2009 Cameron Shorter
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
# This script will install documentation from 

# Running:
# =======
# sudo ./install_main_docs.sh


USER_NAME="user"
USER_HOME="/home/$USER_NAME"
SRC="../doc"
DEST="/usr/local/share/osgeolive-docs"
BASE_FILES="banner.png osgeolive.css" # base files to install
HTML_FILES="contact.html index.html download.html sponsors.html"
INSTALL_APPS=../install_list # List applications to install 
APPS=`sed -e 's/#.*$//' "$INSTALL_APPS" | sort`
VERSION=`cat ../VERSION.txt`
TMP_FILE="/tmp/install_main_docs$$"

apt-get --assume-yes install python-sphinx



# TODO
# Add contributors to the sponsors.html page
#echo "<h1>OSGeo-Live contributors</h1>" >> ${DEST}/sponsors.html
#echo "<p>Thank you to all the following people who have contributed to
#the development of OSGeo-Live:</p>" >> ${DEST}/sponsors.html
#echo "<table>" >> ${DEST}/sponsors.html
#grep -v " *#" ${SRC}/../contributors.csv | cut -f1-3 -d, | \
#  sed -e 's/^/<tr><td>/' -e 's/,/<\/td><td>/g' -e 's/$/<\/td><\/tr>/' \
#      -e 's+<td>\(Name\|Email\|Country\)</td>+<td><u>\1</u></td>+g' \
#      >> ${DEST}/sponsors.html
#echo "</table><br><hr>" >> ${DEST}/sponsors.html


# The index.html file redirects to the English en/index.html
cp ../doc/{index.html,banner.png} ${DEST}

# Build the documentation, using sphinx to convert RST to HTML
# Build docs separately for each Language directory
for LANG in en de; do
  rm -fr ${DEST}/${LANG}
  cd ../doc/${LANG}
  make html
  mv _build/html ${DEST}/${LANG}

  # Correct the index.html files in each directory
  for PAGE_TYPE in overview quickstart standards; do
    if [ -e "../doc/${LANG}/${PAGE_TYPE}" ] ; then
      cd ${PAGE_TYPE}/
      rm ${DEST}/${LANG}/${PAGE_TYPE}/genindex.html
      ln -s ${DEST}/${LANG}/${PAGE_TYPE}/${PAGE_TYPE}.html ${DEST}/${LANG}/${PAGE_TYPE}/index.html
      # Replace the genindex (which doesn't populate) with ${PAGE_TYPE}.html
      ln -s ${DEST}/${LANG}/${PAGE_TYPE}/${PAGE_TYPE}.html ${DEST}/${LANG}/${PAGE_TYPE}/genindex.html
      cd ..
    fi
  done

  # Correct the relative links in headers for the top level directory
  for ITEM in ${HTML_FILES}; do
    #  for ITEM2 in {HTML_FILES} overview/overview.html standards/standards.html; do
    #    sed -e "s#\(../\)\($ITEM2\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    #  done

    # I can't work out how to make use of the variable inside sed, so expanding
    # the for loop below
    sed -e "s#\(../\)\(contact.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    sed -e "s#\(../\)\(index.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    sed -e "s#\(../\)\(download.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    sed -e "s#\(../\)\(sponsors.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    sed -e "s#\(../\)\(overview/overview.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
    sed -e "s#\(../\)\(standards/standards.html\)#\2#" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE};mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
  done

  # Add version to all <h1> headers which contain OSGeo-Live
  for ITEM in quickstart/quickstart.html overview/overview.html ${HTML_FILES}; do
    sed -e "s/\(<h1>.*\)\(OSGeo-Live\)/\1\2 ${VERSION}/" ${DEST}/${LANG}/${ITEM} > ${TMP_FILE}
    mv ${TMP_FILE} ${DEST}/${LANG}/${ITEM}
  done

  cd ../../bin
done


# Download the Test Plan / Test Results
TMPDIR="/tmp/build_docs"
mkdir -p "$TMPDIR"
TMPFILE="$TMPDIR/buildtmp_$$_tests.html"

# Create Symbolic link to Windows and Mac Installer directory on DVD
# (index.html references these directories)
# --probably better to put these in another script--
ln -s /cdrom/WindowsInstallers "$DEST"/..
ln -s /cdrom/MacInstallers "$DEST"/..

wget -nv -O "$TMPFILE" \
  http://wiki.osgeo.org/wiki/Live_GIS_Disc_Testing

FIRSTLINE=`grep -n '<!-- start content -->' "$TMPFILE" | cut -f1 -d:`
LASTLINE=`grep -n '<!-- end content -->' "$TMPFILE" | cut -f1 -d:`
head -n "$LASTLINE" "$TMPFILE" | sed -e "1,${FIRSTLINE}d" > "$TMPDIR/tests_inc.html"
cat "$SRC/pre.html" "$TMPDIR/tests_inc.html" "$SRC/post.html" > "$DEST/tests.html"



echo "install_main_docs.sh: Double-check that the Firefox \
home page is now set to file://$DEST/index.html"
# ~user/.mozilla/ has to exist first, so firefox would have need
#   to been started at least once to set it up

# edit ~user/.mozilla/firefox/$RANDOM.default/prefs.js:
#   user_pref("browser.startup.homepage", "file:///usr/local/share/osgeolive-docs/index.html");

PREFS_FILE=`find "$USER_HOME/.mozilla/firefox/" | grep -w default/prefs.js | head -n 1`
if [ -n "$PREFS_FILE" ] ; then
   sed -i -e 's+\(homepage", "\)[^"]*+\1file:///usr/local/share/osgeolive-docs/index.html+' \
      "$PREFS_FILE"

   # firefox snafu: needed for web apps to work if network is not there
   echo 'user_pref("toolkit.networkmanager.disable", true);' >> "$PREFS_FILE"
   # maybe being online won't stick, but we may as well try:
   echo 'user_pref("network.online", true);' >> "$PREFS_FILE"
fi

# reset the homepage for the main ubuntu-firefox theme too (if present)
if [ -e /etc/xul-ext/ubufox.js  ] ; then
   sed -i -e 's+^//pref("browser.startup.homepage".*+pref("browser.startup.homepage", "file:///usr/local/share/osgeolive-docs/index.html");+' \
       /etc/xul-ext/ubufox.js
fi     

# how about this one?
if [ `grep -c 'osgeolive' /etc/firefox/pref/firefox.js` -eq 0 ] ; then
   echo 'pref("browser.startup.homepage", "file:///usr/local/share/osgeolive-docs/index.html"' \
      >> /etc/firefox/pref/firefox.js
fi

#Alternative, just put an icon on the desktop that launched firefox and points to index.html
\cp -f ../desktop-conf/arramagong-wombat-small.png  /usr/local/share/icons/
#wget -nv  -O /usr/local/share/icons/arramagong-wombat-small.png \
#  "http://svn.osgeo.org/osgeo/livedvd/artwork/backgrounds/arramagong/arramagong-wombat-small.png"

#What logo to use for launching the help?
# HB: IMO wombat roadsign is good- it says "look here" and is friendly
ICON_FILE="live_GIS_help.desktop"
# perhaps: Icon=/usr/share/icons/oxygen/32x32/categories/system-help.png

if [ ! -e "/usr/share/applications/$ICON_FILE" ] ; then
   cat << EOF > "/usr/share/applications/$ICON_FILE"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Help
Comment=Live Demo Help
Categories=Application;Education;Geography;
Exec=firefox /usr/local/share/osgeolive-docs/index.html
Icon=/usr/local/share/icons/arramagong-wombat-small.png
Terminal=false
StartupNotify=false
EOF
fi

\cp -a "/usr/share/applications/$ICON_FILE" "$USER_HOME/Desktop/"
chown $USER_NAME.$USER_NAME "$USER_HOME/Desktop/$ICON_FILE"
# executable bit needed for Ubuntu 9.10's GNOME. Also make the first line
#   of the *.desktop files read "#!/usr/bin/env xdg-open"
#chmod u+x "$USER_HOME/Desktop/$ICON_FILE"


#Should we embed the password file in the help somehow too?
# =note that it needs to be installed first! move here from install_desktop.sh if needed=
