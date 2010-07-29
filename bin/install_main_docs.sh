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

# Requires: abiword for the build process (but abiword can be deleted after that)

USER_NAME="user"
USER_HOME="/home/$USER_NAME"
SRC="../doc"
DEST="/usr/local/share/osgeolive-docs"
BASE_FILES="banner.png osgeolive.css images" # base files to install
HTML_FILES="contact.html index.html sponsors.html"
INSTALL_APPS=../install_list # List applications to install 
APPS=`sed -e 's/#.*$//' "$INSTALL_APPS" | sort`
VERSION=`cat ../VERSION.txt`

# abiword is required to convert .odt files to .html
apt-get install --yes abiword
apt-get --assume-yes install python-sphinx


mkdir -p $DEST/doc

# Copy style sheets and images
for ITEM in $BASE_FILES ; do
   # keep it at one file per line, as missing files tell us what is missing
   cp -prf ${SRC}/"$ITEM" "$DEST/"
done

# Copy pre.html into all the html files
for ITEM in contact.html index.html sponsors.html content.html ; do
  # copy the version number into the <h1>title</h1>
  cat ${SRC}/pre.html > $DEST/$ITEM
done

# Add contributors to the sponsors.html page
echo "<h1>OSGeo Live GIS Disc developers and contributors</h1>" >> ${DEST}/sponsors.html
echo "<p>Thank you to all the following people who have contributed their
 programming time and help to make this Live DVD possible.</p>" >> ${DEST}/sponsors.html
echo "<table>" >> ${DEST}/sponsors.html
grep -v " *#" ${SRC}/../contributors.csv | cut -f1-3 -d, | \
  sed -e 's/^/<tr><td>/' -e 's/,/<\/td><td>/g' -e 's/$/<\/td><\/tr>/' \
      -e 's+<td>\(Name\|Email\|Country\)</td>+<td><u>\1</u></td>+g' \
      >> ${DEST}/sponsors.html
echo "</table>" >> ${DEST}/sponsors.html
echo '<p><i>Source list at: <a href="https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/contributors.csv">https://svn.osgeo.org/osgeo/livedvd/gisvm/trunk/contributors.csv</a></i></p>' >> ${DEST}/sponsors.html

# Copy body of html static files
for ITEM in contact.html index.html sponsors.html content.html; do
  cat ${SRC}/${ITEM} >> $DEST/$ITEM

  # Add version number to header
  sed -e "s/<h1>OSGeo Live GIS Disc/<h1>OSGeo Live GIS Disc ${VERSION}/" ${DEST}/${ITEM} > /tmp/${ITEM}
  mv /tmp/${ITEM} ${DEST}/${ITEM}
done

# Build the application overview pages
cd ../doc/overview/
make html
rm -fr ${DEST}/overview/
mv _build/html ${DEST}/overview/
cd ../../bin

# Build the application quick start pages
cd ../doc/quickstart/
make html
rm -fr ${DEST}/quickstart/
mv _build/html ${DEST}/quickstart/
cd ../../bin

# license page start
#cp -f ${SRC}/license_pre.html "$DEST/license.html"

for ITEM in $APPS ; do
   # Publish Descriptions:

   # Convert .odt description to html if doc exists
   if [ -e "${SRC}/descriptions/${ITEM}_description.odt" ] ; then
      abiword --to "${DEST}/doc/${ITEM}_description.html" "${SRC}/descriptions/${ITEM}_description.odt"

   # Otherwise, copy the HTML
   else
     if [ -e "${SRC}/descriptions/${ITEM}_description.html" ] ; then
       cp -f "${SRC}/descriptions/${ITEM}_description.html" "$DEST/doc/"
     else
       echo "ERROR: install_main_docs.sh: missing doc/descriptions/${ITEM}_description.html"
     fi
   fi

   # Link to the arramagong style file
   # FIXME, we should use the pre.html file for this, or similar, to make easier
   # to maintain
   sed -i -e 's/<head>/<head><link href="..\/osgeolive.css" type="text\/css" rel="stylesheet"\/>/' "$DEST/doc/${ITEM}_description.html"

   # Add Header to the X_description.html file
   # FIXME, we should use the pre.html file for this, or similar, to make easier
   # to maintain
   sed -i -e 's/<body>/<body> <div class="header"><div class="banner"><a href="http:\/\/live.osgeo.org\/"><img src="..\/banner.png"><\/a><\/div><ul>  <li><a href="..\/index.html">Home<\/a><\/li> | <li><a href="..\/content.html">Contents<\/a><\/li> | <li><a href="..\/contact.html">Contact and Support<\/a><\/li> | <li><a href="..\/tests.html">Tests<\/a><\/li> | <li><a href="..\/sponsors.html">Sponsors<\/a><\/li><\/ul><\/div><br \/>/' "$DEST/doc/${ITEM}_description.html"

   # Add Footer to the X_description.html file
   # FIXME, we should use the post.html file for this, or similar, to make easier
   # to maintain
   sed -i -e 's/<\/body>/<div class="footer"> <div class="copyright">\&copy; The Open Source Geospatial Foundation and LISAsoft 2010<\/div> <\/body>/' "$DEST/doc/${ITEM}_description.html"

   # Copy Definitions:
   if [ -e "${SRC}/descriptions/${ITEM}_definition.html" ] ; then
     cp "${SRC}/descriptions/${ITEM}_definition.html" "/tmp/${ITEM}_definition.html"
     if [ -e "${DEST}/overview/${ITEM}_overview.html" ] ; then
       # point the definition file at the overview doc instead of the
       # description doc 
       sed -i -e \
         "s#doc/${ITEM}_description.html#overview/${ITEM}_overview.html#" \
         "/tmp/${ITEM}_definition.html"
     fi

     if [ -e "${DEST}/quickstart/${ITEM}_quickstart.html" ] ; then
       # Add link to Quick Start, if it exists
       echo "Inserting Quick Start for ${ITEM}"
       sed -i -e \
         "s#<.li>#<p>[<a href='quickstart/${ITEM}_quickstart.html'>Quick Start</a>]</p></li>#" \
         "/tmp/${ITEM}_definition.html"
     fi

     cat "/tmp/${ITEM}_definition.html" >> "$DEST/content.html"
     rm "/tmp/${ITEM}_definition.html"
   else
     echo "ERROR: install_main_docs.sh: missing doc/descriptions/${ITEM}_definition.html"
   fi

   # Copy Licenses:
   #if [ -e "${SRC}/descriptions/${ITEM}_license.html" ] ; then
   #   cat "${SRC}/descriptions/${ITEM}_license.html" >> "$DEST/license.html"
   #else
   #  echo "ERROR: install_main_docs.sh: missing doc/descriptions/${ITEM}_license.html"
   #fi
done

# Copy disclaimer to content.html
cat ${SRC}/disclaimer.html >> $DEST/content.html

# Copy post.html into all the html files
for ITEM in contact.html index.html sponsors.html content.html ; do
  cat ${SRC}/post.html >> "$DEST/$ITEM"
done

# license page end
#cat ${SRC}/license_post.html >> "$DEST/license.html"

# Download the Test Plan / Test Results
TMPDIR="/tmp/build_docs"
mkdir -p "$TMPDIR"
TMPFILE="$TMPDIR/buildtmp_$$_tests.html"

# Create Symbolic link to Windows and Mac Installer directory on DVD
# (index.html references these directories)
ln -s /media/cdrom/WindowsInstallers ${DEST}/..
ln -s /media/cdrom/MacInstallers ${DEST}/..

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
# executable bit needed for Ubunti 9.10's GNOME. Also make the first line
#   of the *.desktop files read "#!/usr/bin/env xdg-open"
#chmod u+x "$USER_HOME/Desktop/$ICON_FILE"


#Should we embed the password file in the help somehow too?
# =note that it needs to be installed first! move here from install_desktop.sh if needed=
