#!/bin/sh
# Copyright (c) 2010 The Open Source Geospatial Foundation.
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
# This script will install pyWPS inside apache

# Running:
# =======
# sudo ./install_pywps.sh
#
#
# Uninstall:
# ============
# sudo rm -r /var/www/pywps
# sudo rm -r /etc/apache2/conf.d/pywps


# live disc's username is "user"
USER_NAME="user"
USER_HOME="/home/$USER_NAME"
PYWPS_TMP="/tmp/build_pywps"
PYWPS_VERSION="foss4g2010"
PYWPS_WWW="/var/www/pywps"
PYWPS_CONF="/etc/apache2/conf.d/pywps"
PYWPS_WRAPPER="pywps.cgi"
PYWPS_SVN="http://svn.wald.intevation.org/svn/pywps/branches/pywps-$PYWPS_VERSION"


apt-get --assume-yes install subversion python-minimal

mkdir -p "$PYWPS_TMP"
chmod 755 -R "$PYWPS_TMP"

echo "fetching pywps-$PYWPS_VERSION..."

#downloading pyWPS SVN for FOSS4G
cd ${PYWPS_TMP}
svn checkout $PYWPS_SVN

#Setting up pyWPS
echo "Installing pywps-$PYWPS_VERSION..."
cd "$PYWPS_TMP/pywps-$PYWPS_VERSION/"
python setup.py install



echo "Apache configuration update ..."
# Adding CGI-BIN to apache and pywps directory

mkdir -p "$PYWPS_WWW"
#chmod -R 755 "$PYWPS_WWW"
cd "$PYWPS_WWW"

#Index Page
cat << EOF > "index.html"

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
<body>
<h2>PyWPS requests</h2>
<ul>
<li><a href="http://localhost/pywps/pywps.cgi?request=getcapabilities&service=wps">GetCapabilities</a></li>
<li><a href="http://localhost/pywps/pywps.cgi?service=wps&version=1.0.0&request=describeprocess&identifier=dummyprocess">Describe Dummy Process</a></li>
<li><a href="http://localhost/pywps/pywps.cgi?service=wps&version=1.0.0&request=execute&identifier=dummyprocess&datainputs=[input1=10;input2=10]">Execute Dummy Process</a></li>
</ul>
</body>
</html>
EOF
cat << EOF > "$PYWPS_CONF"		        

<Directory /var/www/pywps/>
	 Options Indexes FollowSymLinks MultiViews
	 AllowOverride All
	 Order allow,deny
	 allow from all
	 AddHandler cgi-script .py .cgi
	 Options FollowSymLinks +ExecCGI
</Directory>	

EOF

echo "Post-install processing..."
PYWPS_WHICH="`which wps.py`"
#Linking to /usr/bin/wps.py (using which just in case....)
ln -s "$PYWPS_WHICH" "$PYWPS_WWW"

#Making Process folder inside /var/www/pywps
mkdir -p "$PYWPS_WWW/processes"
cp $PYWPS_TMP/pywps-$PYWPS_VERSION/tests/processes/* $PYWPS_WWW/processes



echo "Creating wrapper script..."
#Making wrapper script
cat << EOF > "$PYWPS_WRAPPER"		        
#!/bin/sh

# Author: Jachym Cepicky
# Purpose: CGI script for wrapping PyWPS script
# Licence: GNU/GPL
# Usage: Put this script to your web server cgi-bin directory, e.g.
# /usr/lib/cgi-bin/ and make it executable (chmod 755 pywps.cgi)

# NOTE: tested on linux/apache

export PYWPS_CFG="$PYWPS_WWW/pywps.cfg"
export PYWPS_PROCESSES="$PYWPS_WWW/processes"

$PYWPS_WHICH


EOF

# Make it executable
chmod 755 "$PYWPS_WRAPPER"

#Editing the pywps.cfg
echo "editing pywps.cfg..."
#cat /pywps.cfg |sed -e "/abstract=.*/abstract=PyWPS for FOSS4G 2010 example installation" >pywps.cfg
cat "$PYWPS_TMP/pywps-$PYWPS_VERSION/pywps/default.cfg" | \
   sed -e "s/abstract=.*/abstract=PyWPS for FOSS4G 2010 example installation/g" \
   > "$PYWPS_WWW/pywps.cfg"

sed -i -e 's|serveraddress=.*|serveraddress=http://localhost/pywps|g' ${PYWPS_WWW}/pywps.cfg
sed -i -e 's|outputUrl=.*|outputUrl=http://localhost/pywps/wpsoutputs|g' ${PYWPS_WWW}/pywps.cfg # | to avoid problems with //
sed -i -e "s|outputPath=.*|outputPath=$PYWPS_WWW/wpsoutputs|g" ${PYWPS_WWW}/pywps.cfg # Double quotes for force variable replacement

#making temporary wpsoutput folder
mkdir -p "$PYWPS_WWW/wpsoutputs"

# Execute and read permissions 
#chmod -R 777 "$PYWPS_WWW/wpsoutputs"
chown -R www-data.www-data "$PYWPS_WWW/wpsoutputs"


echo "Done."

#Add Launch icon to desktop
#What Icon should be used
	

cat << EOF > /usr/share/applications/pywps.desktop
	[Desktop Entry]
	Type=Application
	Encoding=UTF-8
	Name=pyWPS
	Comment=pyWPS 3.1.0
	Categories=Application;Education;Geography;
	Exec=firefox http://localhost/pywps/index.html
	Icon=gnome-globe
	Terminal=false
	StartupNotify=false
	Categories=Education;Geography;
EOF

chmod 755 /usr/share/applications/pywps.desktop 
cp /usr/share/applications/pywps.desktop "$USER_HOME/Desktop/"		

# Reload Apache
/etc/init.d/apache2 force-reload

