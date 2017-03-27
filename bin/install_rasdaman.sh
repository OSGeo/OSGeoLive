#!/bin/bash
#
# This file is part of rasdaman community.
#
# Rasdaman community is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rasdaman community is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with rasdaman community.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2003-2009 Peter Baumann / rasdaman GmbH.
#
# For more information please see <http://www.rasdaman.org>
# or contact Peter Baumann via <baumann@rasdaman.com>.
#

./diskspace_probe.sh "`basename $0`" begin
BUILD_DIR=`pwd`
####

apt-get install --yes libtiffxx5=4.0.6-1 libtiff5-dev=4.0.6-1
apt-mark hold libtiffxx5
apt-mark hold libtiff5-dev

wget http://download.rasdaman.org/installer/install.sh
sudo bash install.sh -p osgeo
sudo service rasdaman stop
sudo service tomcat8 stop

# Patching the urls in the demo website
sudo sed -i 's/flanche.com:9090/ows.rasdaman.org/g' /var/www/html/rasdaman-demo/demo/demo-frames/2d/app.js
sudo sed -i 's/flanche.com:9090/ows.rasdaman.org/g' /var/www/html/rasdaman-demo/demo/demo-frames/ww3d/app.js

echo "Rasdaman command log:"
echo "==============================================="
cat /tmp/rasdaman_command_log
echo "==============================================="

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
