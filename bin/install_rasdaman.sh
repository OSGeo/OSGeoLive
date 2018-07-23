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

setup_rasdaman_repo()
{
  echo "Setup rasdaman package repository..."
  # add rasdaman public key
  local rasdaman_pkgs_url="http://download.rasdaman.org/packages"
  wget -q -O - "$rasdaman_pkgs_url/rasdaman.gpg" | apt-key add - \
    || { echo "Failed importing rasdaman GPG key."; return 1; }
  # add rasdaman repo
  local codename="$1"
  local release="$2"
  echo "deb [arch=amd64] $rasdaman_pkgs_url/deb $codename $release" > /etc/apt/sources.list.d/rasdaman.list
}

install_rasdaman_pkg()
{
  echo "Install rasdaman package..."
  apt-get -qq update -y
  # automate any configuration update dialog
  export DEBIAN_FRONTEND=noninteractive
  apt-get -o Dpkg::Options::="--force-confdef" install -y rasdaman \
    || { echo "Failed installing rasdaman package."; return 1; }
  # make sure the rasdaman package is not removed by apt-get autoremove
  echo "rasdaman hold" | dpkg --set-selections
  # apt-mark manual rasdaman
  apt-get -q install python-glob2
  echo
  echo "Rasdaman package installed successfully."
  echo
}

replace_rasdaman_user_with_system_user()
{
  local rasdaman_user=rasdaman
  local rasdaman_group=rasdaman
  echo "Replacing regular user '$rasdaman_user' with a system user..."
  userdel $rasdaman_user || { echo "Failed removing rasdaman user."; return 1; }
  groupdel $rasdaman_group > /dev/null 2>&1

  adduser --system --group --home /opt/rasdaman --no-create-home --shell /bin/bash $rasdaman_user
  chown -R $rasdaman_user:$rasdaman_group /opt/rasdaman
  # this directory is owned by an invalid uid after the user change, it can be just deleted
  rm -rf /tmp/rasdaman_*
  # add rasdaman user to tomcat8 group
  adduser $rasdaman_user tomcat8
  # and user to rasdaman group
  adduser $USER_NAME $rasdaman_group
}

create_bin_starters()
{
  echo "Creating starting scripts..."
  cat > $RMANHOME/bin/rasdaman-start.sh <<EOF
#!/bin/bash
sudo service tomcat8 start
sudo service rasdaman start
echo "Preparing demo data..."
$RMANHOME/bin/rasdaman-osgeo-demo.sh &> /dev/null
$RMANHOME/bin/petascope-osgeo-demo.sh &> /dev/null
echo "Demo data prepared successfully."
echo "Rasdaman was started correctly."
EOF
  cat > $RMANHOME/bin/rasdaman-stop.sh <<EOF
#!/bin/bash
sudo service tomcat8 stop
sudo service rasdaman stop
echo -e "Rasdaman stopped."
EOF
  chmod 755 $RMANHOME/bin/rasdaman-start.sh $RMANHOME/bin/rasdaman-stop.sh
}

create_demo_scripts()
{
  echo "Creating demo scripts..."
  cat > $RMANHOME/bin/rasdaman-osgeo-demo.sh <<EOF
#!/bin/bash
rasdaman_demo_created="$RMANHOME/rasdaman_demo_success"
if [ ! -f "\$rasdaman_demo_created" ]; then
    echo "Ingesting rasdaman data..."
    $RMANHOME/bin/rasdaman_insertdemo.sh localhost 7001 \
      $RMANHOME/share/rasdaman/examples/images rasadmin rasadmin
    sudo touch "\$rasdaman_demo_created"
    echo "Rasdaman data ingested successfully."
fi
EOF
  cat > $RMANHOME/bin/petascope-osgeo-demo.sh <<EOF
#!/bin/bash
petascope_demo_created=$RMANHOME/petascope_demo_success
wcst_import="$RMANHOME/bin/wcst_import.sh"
ingest_path="$RMANHOME/ingest"
if [ ! -f "\$petascope_demo_created" ]; then
    echo "Ingesting Petascope data..."
    sudo $RMANHOME/bin/petascope_insertdemo.sh
    for ingredients in NIR NN3_1 lena; do
      sudo \$wcst_import \$ingest_path/\$ingredients.json
    done
    sudo touch "\$petascope_demo_created"
    echo "Petascope data ingested successfully."
fi
EOF
  chmod 755 $RMANHOME/bin/rasdaman-osgeo-demo.sh $RMANHOME/bin/petascope-osgeo-demo.sh
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
Exec=$RMANHOME/bin/rasdaman-start.sh
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
Exec=$RMANHOME/bin/rasdaman-stop.sh
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

delete_not_needed_files()
{
  # remove development stuff
  for f in lib include share/rasdaman/war; do
    rm -rf $RMANHOME/$f
  done
  # strip executables
  for f in $RMANHOME/bin/*; do
    strip $f > /dev/null 2>&1 || true
  done
}

deploy_local_earthlook()
{
  echo "Deploying local earthlook..."
  local tmp_dir=/tmp/earthlook
  local data_url="http://kahlua.eecs.jacobs-university.de/~earthlook/osgeo/earthlook.tar.gz"

  mkdir -p "$tmp_dir"
  pushd "$tmp_dir" > /dev/null
  # download data
  wget -q "$data_url" -O earthlook.tar.gz
  # extract
  tar xzf earthlook.tar.gz
  local rasdaman_demo_path="/var/www/html/rasdaman-demo"
  rm -rf "$rasdaman_demo_path"
  mkdir -p /var/www/html/
  # deploy
  mv public_html "$rasdaman_demo_path"
  chmod 755 "$rasdaman_demo_path"
  popd > /dev/null

  rm -rf "$tmp_dir"
}

setup_ingestion_ingredients()
{
  echo "Creating ingestion ingredients for demo data..."
  local ingest_dir=$RMANHOME/ingest
  local coverage=
  local ingredients=
  mkdir -p "$ingest_dir"
  for coverage in NIR NN3_1 lena; do
    ingredients="$ingest_dir/$coverage.json"
    cat > "$ingredients" <<EOF
{
  "config": {
    "service_url": "http://localhost:8080/rasdaman/ows",
    "tmp_directory": "/tmp/",
    "crs_resolver": "http://localhost:8080/def/",
    "default_crs": "http://localhost:8080/def/OGC/0/Index2D",
    "mock": false,
    "automated": true,
    "subset_correction" : false
  },
  "input": {
    "coverage_id": "$coverage"
  },
  "recipe": {
    "name": "wcs_extract",
    "options": {
      "coverage_id" : "$coverage",
      "wcs_endpoint" : "http://ows.rasdaman.org/rasdaman/ows"
    }
  }
}
EOF
  done
}

add_rasdaman_path_to_bashrc()
{
  echo "Add rasdaman profile to the user's bashrc..."
  echo "source /etc/profile.d/rasdaman.sh" >> "$USER_HOME/.bashrc"
}

#
# Install and setup demos
#

setup_rasdaman_repo "bionic" "stable"
install_rasdaman_pkg

sudo -u rasdaman /opt/rasdaman/bin/stop_rasdaman.sh
sudo service tomcat8 stop

replace_rasdaman_user_with_system_user
create_bin_starters
create_demo_scripts
create_desktop_applications
delete_not_needed_files
deploy_local_earthlook
setup_ingestion_ingredients
add_rasdaman_path_to_bashrc


echo "Rasdaman command log:"
echo "==============================================="
cat /tmp/rasdaman_command_log
echo "==============================================="

####
"$BUILD_DIR"/diskspace_probe.sh "`basename $0`" end
