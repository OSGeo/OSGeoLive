OSGeo live installation scripts
===============================
OSGeo-Live_ is a self-contained bootable DVD, USB thumb drive or Virtual Machine based on Lubuntu, that allows you to try a wide variety of open source geospatial software without installing anything. It is composed entirely of free software, allowing it to be freely distributed, duplicated and passed around.

The set of scripts in this repository will make a GIS Virtual
Machine or bootable ISO from a base Lubuntu 18.04 (Bionic) system.

Running:
~~~~~~~~

You can install individual applications in the base Lubuntu system by running bin/install*sh scripts.

Up to date instructions on building a VM or an ISO image are given at:
http://wiki.osgeo.org/wiki/Live_GIS_Build

File Structure:
~~~~~~~~~~~~~~~

bin/
     /setup.sh # Download, and install all core files and set up config files
     /install_project1.sh # Download, and install all files for project1
     /install_project2.sh # Download, and install all files for project2
     /install_desktop.sh
     /install_main_docs.sh
     /setdown.sh

     /build_iso.sh
       /load_mac_installers.sh
	 /load_win_installers.sh

     bootstrap.sh
     inchroot.sh
     package.sh
     sync_livedvd.sh

app-conf/
     /project1/   # config files used by install_package1.sh script
     /project2/   # config files used by install_package2.sh script

app-data/
     /project1/   # data & help files used by package1
     /project2/   # data & help files used by package2

desktop-conf/	  # data files and images used for the main desktop background
     
sources.list.d/ # Supplimentary package repositories for /etc/apt/sources.list

.. _OSGeo-Live: https://live.osgeo.org
