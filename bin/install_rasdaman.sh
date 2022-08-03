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

# NOTE: this script is executed with root
if [ -z "$USER_NAME" ] ; then
   USER_NAME="user"
fi
USER_HOME="/home/$USER_NAME"

RMANHOME=/opt/rasdaman

install_rasdaman_pkg()
{
  local archive="rasdaman-osgeolive-package.tar.gz"
  local archive_url="http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo/$archive"

  echo "Installing rasdaman into $RMANHOME..."
  mkdir -p $RMANHOME
  pushd $RMANHOME > /dev/null
  wget -q "$archive_url" -O - | tar xz
  echo "Installed size: $(du -sh .)"
  chown -R root: $RMANHOME
  chmod -R 777 $RMANHOME/log
  popd > /dev/null
}

install_rasdaman_dependencies()
{
  echo "Installing rasdaman dependencies"
  # nothing extra needed
}

create_desktop_applications()
{
  echo "Creating desktop icons..."
  for path in /usr/local/share/applications/ $USER_HOME/Desktop/; do
    mkdir -p $path
  cat > $path/start_rasdaman_server.desktop <<EOF
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Start Rasdaman Server
Comment=Start Rasdaman Server
Categories=Application;Education;Geography;
Exec=/opt/rasdaman/bin/start_rasdaman.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF
  cat > $path/stop_rasdaman_server.desktop <<EOF
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Stop Rasdaman Server
Comment=Stop Rasdaman Server
Categories=Application;Education;Geography;
Exec=/opt/rasdaman/bin/stop_rasdaman.sh
Icon=gnome-globe
Terminal=true
StartupNotify=false
EOF
  cat > $path/rasdaman_earthlook_demo.desktop <<EOF
[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=Rasdaman-Earthlook Demo
Comment=Rasdaman Demo and Tutorial
Categories=Application;Education;Geography;
Exec=firefox http://localhost/rasdaman-demo/
Icon=gnome-globe
Terminal=false
StartupNotify=false
EOF

    for f in $path/start_rasdaman_server.desktop $path/stop_rasdaman_server.desktop $path/rasdaman_earthlook_demo.desktop; do
      chown $USER_NAME: $f
      chmod 755 $f
    done
  done
  chown $USER_NAME: $USER_HOME/Desktop/
}

install_systemd_unit()
{
  local dst="/etc/systemd/system/rasdaman.service"
  echo "Installing systemd unit script into $dst"
  cat > "$dst" <<EOF
[Unit]
Description=Rasdaman Array Database
Documentation=https://rasdaman.org

[Service]
Type=forking
Restart=no
TimeoutSec=30
IgnoreSIGPIPE=no
KillMode=process
GuessMainPID=no
RemainAfterExit=no
PIDFile=/var/run/rasmgr.pid
ExecStart=/opt/rasdaman/bin/start_rasdaman.sh
ExecStop=/opt/rasdaman/bin/stop_rasdaman.sh

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable rasdaman.service
}

add_rasdaman_path_to_bashrc()
{
  echo "Add rasdaman path to the user's bashrc..."
  echo "export RMANHOME=/opt/rasdaman" >> "$USER_HOME/.bashrc"
  echo "export RASDATA=\$RMANHOME/data" >> "$USER_HOME/.bashrc"
  echo "export PATH=\$PATH:\$RMANHOME/bin" >> "$USER_HOME/.bashrc"
}

deploy_local_earthlook()
{
  echo "Deploying local earthlook..."
  local tmp_dir=$RMANHOME/earthlook

  local rasdaman_demo_path="/var/www/html/rasdaman-demo"
  rm -rf "$rasdaman_demo_path"
  mkdir -p /var/www/html/

  # deploy
  mv "$tmp_dir" "$rasdaman_demo_path"
  chmod 755 "$rasdaman_demo_path"
}

update_libgdal_java()
{
  # copy v3.2 of libgdal-java jni libs, see https://trac.osgeo.org/osgeolive/ticket/2288
  local v32="$RMANHOME/libgdal-java"
  if [ -d "$v32" ]; then
    mkdir -p /usr/lib/jni/
    mv $v32/* /usr/lib/jni/ && \
      rm -rf $v32
  fi
}

#
# Install and setup demos
#

install_rasdaman_pkg
install_rasdaman_dependencies
install_systemd_unit
create_desktop_applications
add_rasdaman_path_to_bashrc
deploy_local_earthlook
#update_libgdal_java

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
