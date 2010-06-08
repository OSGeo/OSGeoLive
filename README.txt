The set of scripts in this directory tree will make a GIS Virtual
Machine and bootable ISO from a base Xubuntu system.


Running:
=======

sudo ./bin/main.sh
#Suggested method of running includes piping all the information to logs
sudo ./main.sh 2>&1 | tee /var/log/live/main_install.log

File Structure:
==============

bin/
     /main.sh # Call all the other scripts
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
     
doc/
     /index_pre.html		# header for summary help page
     /index_post.html		# footer for summary help page
     /arramagong.css
     /jquery.js
     /template_definition.html	# example of project_definition.html file
     /template_description.html	# example of project_description.html file
     /template_licence.html	# incorportate into project_description.html???

     /descriptions/
       /package_definition.html    # short (1 sentence) summary of installed pkg 
       /package_description.html   # getting started instructions for the LiveDVD user

download/	# copy of the livedvd project's download server webpage

sources.list.d/ # Supplimentary package repositories for /etc/apt/sources.list



SVN repository structure:
=========================

trunk/      # main development
branches/   # old releases (viable; open to bug fixes)
     /arramagong_2/   # the 2.0.x release branch (based on Xununtu 9.04)

tags/       # versioned release snapshots (do not edit)
     /release_20090930_arramagong_2_0_3/   # the 2.0.3 release (Sept 30, 2009)


