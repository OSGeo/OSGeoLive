#!/bin/sh
# Copyright (c) 2016 The Open Source Geospatial Foundation.
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
#
# About:
# =====
# This script will install pywps as follows
# - python-pywps debian package
# - /etc/pywps (configuration, WSGI wrapper, processes)
# - /etc/apache2/sites-available/pywps.conf
# - /usr/share/applications/pywps.desktop
#
# Requires: Apache2, Python, python-pywps
#
# Uninstall:
# ============
# sudo apt-get remove python libapache2-mod-wsgi python-pywps
#
# sudo a2disconf pywps
# sudo a2dismod wsgi
# sudo apache2ctl restart
# sudo rm -fr /etc/pywps
# sudo rm -f /etc/apache2/conf-available/pywps.conf
# sudo rm -f /usr/share/applications/pywps.desktop
# sudo rm -f /home/$USER_NAME/Desktop/pywps.desktop


./diskspace_probe.sh "`basename $0`" begin
####

# live disc's username is "user"
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

echo 'Installing PyWPS ...'

apt-get install --yes python libapache2-mod-wsgi python-pywps

PYWPS_ETC=/etc/pywps
PYWPS_PROCESSES=$PYWPS_ETC/processes
PYWPS_CFG=$PYWPS_ETC/pywps.cfg
PYWPS_WSGI=$PYWPS_ETC/wps.py
PYWPS_APACHE_CONF=/etc/apache2/conf-available/pywps.conf
PYWPS_URL=http://localhost/pywps/wps.py
PYWPS_DESKTOP=/usr/share/applications/pywps.desktop

echo 'Setting up directories'

mkdir -p "$PYWPS_PROCESSES"

echo 'Downloading logo'

wget -c --progress=dot:mega \
   -O /usr/local/share/icons/pywps.png \
   "http://pywps.org/images/pywps.png"

echo 'creating PyWPS configuration'

cat << EOF > "$PYWPS_CFG"
[wps]
encoding=utf-8
title=PyWPS OSGeo-Live Demo
version=1.0.0
abstract=PyWPS is an implementation of the Web Processing Service standard from the Open Geospatial Consortium. PyWPS is written in Python.
fees=None
constraints=None
serveraddress=$PYWPS_URL
keywords=PyWPS,WPS,OGC,processing,ogc,interoperability
lang=en-US

[provider]
providerName=Organization Name
individualName=Lastname, Firstname
positionName=Position Title
role=pointOfContact
deliveryPoint=Mailing Address
city=City
postalCode=Zip or Postal Code
country=Country
electronicMailAddress=Email Address
providerSite=http://pywps.org
phoneVoice=+xx-xxx-xxx-xxxx
phoneFacsimile=+xx-xxx-xxx-xxxx
administrativeArea=Administrative Area

[server]
maxoperations=50
maxinputparamlength=1024
maxfilesize=3mb
tempPath=/tmp
debug=true
EOF

echo 'creating WSGI wrapper'

cat << EOF > "$PYWPS_WSGI"
import os
import pywps
from pywps.Exceptions import NoApplicableCode, WPSException


def application(environ, start_response):

    os.environ['PYWPS_CFG'] = environ['PYWPS_CFG']
    os.environ['PYWPS_PROCESSES'] = environ['PYWPS_PROCESSES']

    status = '200 OK'
    response_headers = [('Content-type', 'text/xml')]
    start_response(status, response_headers)

    inputQuery = None
    if "REQUEST_METHOD" in environ and environ["REQUEST_METHOD"] == "GET":
        inputQuery = environ["QUERY_STRING"]
    elif "wsgi.input" in environ:
        inputQuery = environ['wsgi.input']

    if not inputQuery:
        err = NoApplicableCode("No query string found.")
        return [err.getResponse()]

    # create the WPS object
    try:
        wps = pywps.Pywps(environ["REQUEST_METHOD"])
        if wps.parseRequest(inputQuery):
            pywps.debug(wps.inputs)
            wps.performRequest()
            return wps.response
    except WPSException as e:
        return [e]
    except Exception as e:
        return [e]
EOF

echo 'creating PyWPS processes'

cat << EOF > "$PYWPS_PROCESSES/__init__.py"
__all__ = ['hello_world']
EOF

cat << EOF > "$PYWPS_PROCESSES/hello_world.py"
from pywps.Process import WPSProcess
class HelloWorldProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(
            self,
            version='0.1.0',
            identifier='hello-world',
            title='Hello World',
            abstract='Sample process',
            storeSupported=False,
            statusSupported=False)

        self.data = self.addComplexInput(identifier='name',
                                         title='Name')

        self.out = self.addComplexOutput(identifier='output',
                                         title='Output')

    def execute(self):
        value = self.data.getValue()
        self.out.setValue('Hello World from %s' % value)
        return
EOF

echo 'creating Apache configuration'

cat << EOF > "$PYWPS_APACHE_CONF"
WSGIScriptAlias /pywps/wps.py $PYWPS_WSGI
<Location /pywps/wps.py>
  SetEnv PYWPS_CFG $PYWPS_CFG
  SetEnv PYWPS_PROCESSES $PYWPS_PROCESSES
</Location>
EOF

echo 'creating desktop launcher'

cat << EOF > "$PYWPS_DESKTOP"
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=PyWPS
Comment=PyWPS
Categories=Application;Education;Geography;WPS
Exec=firefox $PYWPS_URL?service=WPS&version=1.0.0&request=GetCapabilities
Icon=/usr/local/share/icons/pywps.png
Terminal=false
StartupNotify=false
Categories=Education;Geography;
EOF

cp "$PYWPS_DESKTOP" "$USER_HOME/Desktop"
chown "$USER_NAME.$USER_NAME" "$USER_HOME/Desktop/pywps.desktop"

echo 'enabling Apache wsgi module'
a2enmod wsgi
echo 'enabling Apache configuration'
a2enconf pywps

####
./diskspace_probe.sh "`basename $0`" end
