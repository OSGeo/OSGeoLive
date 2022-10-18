# OSGeoLive

[OSGeoLive](https://live.osgeo.org) is a self-contained bootable DVD, USB thumb drive or Virtual Machine based on Lubuntu, that allows you to try a wide variety of open source geospatial software without installing anything. It is composed entirely of free software, allowing it to be freely distributed, duplicated and passed around.

## OSGeoLive installation scripts

The set of scripts in this repository will make a GIS Virtual Machine or bootable ISO from a base Lubuntu 22.04 (Jammy) system.

### Running installers

You can install individual applications in the base Lubuntu system by running `bin/install*.sh` scripts.

### File Structure

```
     bin/
          /setup.sh # Download, and install all core files and set up config files
          /install_project1.sh # Download, and install all files for project1
          /install_project2.sh # Download, and install all files for project2
          /install_desktop.sh
          /install_main_docs.sh
          /setdown.sh
          bootstrap.sh
          inchroot.sh
     app-conf/
          /project1/   # config files used by install_package1.sh script
          /project2/   # config files used by install_package2.sh script
     app-data/
          /project1/   # data & help files used by package1
          /project2/   # data & help files used by package2
     desktop-conf/	   # data files and images used for the main desktop background
     sources.list.d/   # Supplimentary package repositories for /etc/apt/sources.list
```

## How to add your project to OSGeoLive

Instructions for adding [new projects](https://wiki.osgeo.org/wiki/Live_GIS_Add_Project)

## Build the OSGeoLive DVD ISO image

### Build ISO

This section describes the new method for building OSGeoLive as described in [official ubuntu wiki](https://help.ubuntu.com/community/LiveCDCustomization). This section is self-contained and there is no need to perform any of the procedures described above.

All you need is a running Ubuntu/Xubuntu/Kubuntu/Lubuntu installation (even within a virtual machine as long as it has \~20GB free disk space). All needed to be done are the following steps under a "user" account:

* Bootstrap the host operating system. If you use the system to build more than once, then this must be done only for the first build

```
     host$ cd /tmp
     host$ wget https://github.com/OSGeo/OSGeoLive/raw/master/bin/bootstrap.sh
     host$ chmod a+x bootstrap.sh
     host$ sudo ./bootstrap.sh
```

This will install Git and the install scripts, and create a link to them from your home directory.

* Set the Version Number and Changes:
     * Update [VERSION.txt](https://github.com/OSGeo/OSGeoLive/blob/master/VERSION.txt) with the current version number.
     * Update [CHANGES.txt](https://github.com/OSGeo/OSGeoLive/blob/master/CHANGES.txt) with changes since the last release.
     * This list can be a summary of the [revision log](https://github.com/OSGeo/OSGeoLive/commits/master) between releases.
     * Commit the changes to Git through a Pull Request right before a release build.

* Execute the build script:
```
     host$ cd ~/gisvm/bin
     host$ sudo ./build_chroot.sh amd64 release master OSGeo 2>&1 | tee /var/log/osgeolive/chroot-build.log
```

* Compress the logs:
```
     host$ cd ~/livecdtmp
     host$ tar czf version-log.tar.gz -C /var/log osgeolive
```

* After the completion of the above script the new iso file is located in \~/livecdtmp along with the build logs. In case you wish to rerun the build process, do not remove or move the lubuntu official iso located in this folder to skip downloading it again.

* It is required to reboot your host machine after build is completed

* Once the ISO is complete copy it out to a server (a local server is fastest)
```
     scp ~/livecdtmp/osgeolive-mini-8.0.iso user@server.org:destination/path/
     scp ~/livecdtmp/osgeolive-mini-8.0-log.tar.gz user@server.org:destination/path/
```

* And/OR wget or scp the file to the upload.osgeo.org server (Note wget is much faster if you have a good webserver to host from)

### How to do development / debugging with the current build method

We have created a debug build process so that projects can now easily create their own iso, including parts of the OSGeoLive (eg only one project) in order to test if the installer scripts work well under this new build method. Here are the steps to debug/test your application:

#### One time steps

You will need to create a pure Lubuntu Virtual Machine setup:

* Download lubuntu-22.04-desktop-amd64.iso from [lubuntu web site](http://cdimage.ubuntu.com/lubuntu/releases/22.04/release/lubuntu-22.04-desktop-amd64.iso).

* Download and install VirtualBox.

* Create a fresh VM installation of Lubuntu. You will need to create a virtual disk drive with at least 25 GB of space and allocate 768MB of RAM to the VM. During installation set the username to "user" and hostname to "osgeolive". DO NOT install system updates during lubuntu installation or after the installation is done. At this moment we work with the default kernel included in lubuntu.

* After the VM is done, login as "user" and open a terminal.

* Bootstrap the VM:
```
     osgeolive$ cd /tmp
     osgeolive$ wget https://github.com/OSGeo/OSGeoLive/raw/master/bin/bootstrap.sh
     osgeolive$ chmod a+x bootstrap.sh
     osgeolive$ sudo ./bootstrap.sh
```

This will install Git, the install scripts, and create a link to them from your home directory.

#### Steps to create the build (repeat as much as needed)

* Make changes to your project's installation script and commit to Git.

* Update the git code:
```
     osgeolive$ cd ~/gisvm
     osgeolive$ git pull origin master
```

* Open file `inchroot.sh` with an editor and comment out all scripts you do not need for your test.
```
     osgeolive$ cd ~/gisvm/bin
     osgeolive$ vi inchroot.sh
```
* Always leave un-commented the following scripts: `setup.sh`, `install_services.sh`, `install_mysql.sh`, `install_java.sh`, `install_apache2.sh`, `install_tomcat.sh`, `install_desktop.sh` and `setdown.sh`. 

* Save your changes and execute the build:
```
     osgeolive$ cd ~/gisvm/bin
     osgeolive$ sudo ./build_chroot.sh amd64 2>&1 | tee /var/log/osgeolive/chroot-build.log
```

* After a while the iso will be created in \~livecdtmp/

* Do not delete the file \~/livecdtmp/lubuntu-22.04-desktop-amd64.iso as it will be needed for next build (saves time not to download again)

* Logs are created at /var/log/osgeolive/chroot-build.log

* Copy the iso and test


## Build the OSGeoLive DVD VM image

### Create the VM

The OSGeoLive Virtual Machine creation process is now exactly similar to a plain Lubuntu VM installation.
Use the mini iso file that was created from the previous chapter. 
Instructions can be found in the OSGeoLive [Documentation](https://live.osgeo.org/en/quickstart/virtualization_quickstart.html)

### Package the VM

From within the VM, fill empty space with zeros in order to be able to shrink the virtual disk files:
```
     osgeolive$ sudo ~/gisvm/bin/zerofill.sh
```
Shrink the virtual machine: 
```
     host$ VBoxManage modifyhd osgeolive.vdi --compact
```
Convert to vmdk format (more widely compatible):
```
     host$ VBoxManage clonehd osgeolive.vdi osgeolive-15.0-amd64.vmdk --format VMDK
```
OR with a recent version of QEMU
```
     host$ qemu-img convert -f vdi -o compat6 -O vmdk osgeolive.vdi osgeolive-15.0-amd64.vmdk
```
Zip the image up:
```
     host$ 7z a -mx=9 osgeolive-15.0-amd64.vmdk.7z osgeolive-15.0-amd64.vmdk
```
Create the md5sum checksums, so which can be used to confirm that the images have been downloaded correctly:
```
     host$ md5sum *.7z*
```

## Upload the Release

### Upload to sourceforge

As of 6.0 the official releases are hosted on sourceforge. To upload you need a sourceforge account and permissions to the osgeo-live project upload.
```
     host$ rsync -e ssh osgeolive-15.0-amd64.iso username,osgeo-live@frs.sourceforge.net:/home/pfs/project/o/os/osgeo-live/15.0/
```

### Upload to the OSGeo Server

```
     host$ scp -pr osgeolive-15.0-amd64.iso username@upload.osgeo.org:/osgeo/download/livedvd/
```
or
```
     host$ rsync --progress -e ssh osgeolive-15.0-amd64.iso username@upload.osgeo.org:/osgeo/download/livedvd/
```

Check the result at: http://download.osgeo.org/livedvd
