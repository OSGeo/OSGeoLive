#!/bin/bash

declare -a DESKTOP_DIRS=("Desktop GIS" "Navigation and Maps" "Web Services" "Browser Clients" "Spatial Tools" "Databases")
cd ~/Desktop

for file in *.desktop ; do
	gio set "$file" "metadata::trusted" true
done

for DIR in "${DESKTOP_DIRS[@]}"; do
	cd "$DIR"
	for file in ~/Desktop/"$DIR"/*.desktop ; do
		gio set "$file" "metadata::trusted" true
	done
	cd ..
done
