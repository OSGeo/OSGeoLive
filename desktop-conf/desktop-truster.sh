#!/bin/sh

declare -a DESKTOP_DIRS=("Desktop GIS" "Navigation and Maps" "Web Services" "Browser Clients" "Spatial Tools" "Databases")
cd ~
for file in *.desktop ; do
  gio set $file "metadata::trusted" true
done

# pwd
for DIR in "${DESKTOP_DIRS[@]}"; do
  cd $DIR
  for file in *.desktop ; do
    gio set $file "metadata::trusted" true
  done
  cd ..
done
