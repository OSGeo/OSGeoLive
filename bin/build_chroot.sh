#!/bin/sh
#############################################################################
# 
# Purpose: Creating OSGeoLive as an Ubuntu customization
#          https://help.ubuntu.com/community/LiveCDCustomization
# Authors: Alex Mandel <tech_dev@wildintellect.com>
#          Angelos Tzotsos <tzotsos@gmail.com>
#
#############################################################################
# Copyright (c) 2013-2016 Open Source Geospatial Foundation (OSGeo) and others.
#
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
#############################################################################
#
# System Requirements
#
#     1. At least 3-5 GB of free space
#     2. At least 512 MB RAM and 1 GB swap (recommended)
#     3. squashfs-tools
#     4. genisoimage, which provides mkisofs
#     5. syslinux-utils, which provides isohybrid
#     6. An Ubuntu kernel with squashfs support (present in Ubuntu 6.06 and later)
#     7. QEMU/KVM, VirtualBox or VMware for testing (optional) 
#
#############################################################################

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Wrong number of arguments"
    echo "Usage: build_chroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi

if [ "$1" != "i386" ] && [ "$1" != "amd64" ] ; then
    echo "Did not specify build architecture, try using i386 or amd64 as an argument"
    echo "Usage: build_chroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi
ARCH="$1"

if [ "$2" != "release" ] && [ "$2" != "nightly" ] ; then
    echo "Did not specify build mode, try using release or nightly as an argument"
    echo "Usage: build_chroot.sh ARCH(i386 or amd64) MODE(release or nightly) [git_branch (default=master)] [github_username (default=OSGeo) or git clone url]"
    exit 1
fi
BUILD_MODE="$2"

if [ "$#" -eq 4 ]; then
    GIT_BRANCH="$3"
    GIT_USER="$4"
elif [ "$#" -eq 3 ]; then
    GIT_BRANCH="$3"
    GIT_USER="OSGeo"
else
    GIT_BRANCH="master"
    GIT_USER="OSGeo"
fi

echo
echo "==============================================================="
echo "Build parameters"
echo "==============================================================="

echo "ARCH: $ARCH"
echo "MODE: $BUILD_MODE"
if echo "$GIT_USER" | grep -q "://"; then
    echo "Git repository: $GIT_USER"
else
    echo "Git repository: https://github.com/$GIT_USER/OSGeoLive.git"
fi
echo "Git branch: $GIT_BRANCH"

DIR="/usr/local/share/gisvm/bin"
GIT_DIR="/usr/local/share/gisvm"
VERSION=`cat "$DIR"/../VERSION.txt`
PACKAGE_NAME="osgeolive"
cd "$GIT_DIR"
REVISION=`git show-ref --head --hash head --hash=7`
REVISION_FULL=`git show-ref --head --hash head`

GIT_BUILD=`git describe --long --tags | awk -F'-' '{print $2}'`

#Selecting iso name and build name
if [ "$BUILD_MODE" = "release" ]; then
    ISO_NAME="$PACKAGE_NAME-$VERSION-$ARCH"
    VERSION_MODE="$VERSION"
else
    ISO_NAME="$PACKAGE_NAME-nightly-build$GIT_BUILD-$ARCH-$REVISION-$GIT_BRANCH"
    VERSION_MODE="build$GIT_BUILD-$REVISION"
fi

#Volume name, max 11 chars:
IMAGE_NAME=OSGEOLIVE`echo "$VERSION" | cut -d '.' -f 1`
#IMAGE_NAME=OSGEOLIVE`echo "$VERSION" | sed -e 's/\.//' -e 's/rc.*//'`


echo
echo "==============================================================="
echo "Start Building $ISO_NAME"
echo "==============================================================="

#Some initial cleaning
#  when run as root, ~ is /root/.
rm -rf ~/livecdtmp/edit
rm -rf ~/livecdtmp/lzfiles

echo
echo "Installing build tools"
echo "======================"

sudo apt-get install --yes squashfs-tools genisoimage syslinux-utils lzip binwalk

#TODO add wget to grab a fresh image, optional

echo
echo "Downloading Lubuntu original image..."
echo "====================================="

#Stuff to be done the 1st time, should already be in place for additional builds
#Download into an empty directory 
mkdir -p ~/livecdtmp
cd ~/livecdtmp
#mv ubuntu-9.04-desktop-i386.iso ~/livecdtmp
UBU_MIRROR="http://cdimage.ubuntu.com"
UBU_RELEASE="18.04"
ISO_RELEASE="18.04.2"
UBU_ISO="lubuntu-${ISO_RELEASE}-desktop-$ARCH.iso"
wget -c --progress=dot:mega \
   "$UBU_MIRROR/lubuntu/releases/$UBU_RELEASE/release/$UBU_ISO"

#Start with a fresh copy
#Mount the Desktop .iso
mkdir mnt
sudo mount -o loop "$UBU_ISO" mnt
echo "Lubuntu $ISO_RELEASE $ARCH image mounted."

#Extract .iso contents into dir 'extract-cd' 
mkdir "extract-cd"
rsync --exclude=/casper/filesystem.squashfs -a mnt/ "extract-cd"

echo
echo "Extracting squashfs from Lubuntu image"
echo "======================================"
#Extract the SquashFS filesystem 
sudo unsquashfs mnt/casper/filesystem.squashfs
#Does the above need to be done every time or can it be done once, and then
# just make a fresh copy of the chroot for each builds
sudo mv squashfs-root edit

echo
echo "Setting up network for chroot"
echo "======================================"
#If you need the network connection within chroot 
sudo cp /etc/resolv.conf edit/etc/
sudo cp /etc/hosts edit/etc/

#These mount important directories of your host system - if you later
# decide to delete the edit/ directory, then make sure to unmount
# before doing so, otherwise your host system will become unusable at
# least temporarily until reboot
sudo mount --bind /dev/ edit/dev

echo
echo "Starting build in chroot"
echo "======================================"

#NOW IN CHROOT
#sudo chroot edit
sudo cp "$DIR"/inchroot.sh ~/livecdtmp/edit/tmp/
sudo cp "$DIR"/bootstrap.sh ~/livecdtmp/edit/tmp/
sudo cp "$GIT_DIR"/VERSION.txt ~/livecdtmp/edit/tmp/
sudo cp "$GIT_DIR"/CHANGES.txt ~/livecdtmp/edit/tmp/
sudo chroot edit /bin/sh /tmp/inchroot.sh "$ARCH" "$BUILD_MODE" "$GIT_BRANCH" "$GIT_USER"

#exit
#OUT OF CHROOT
echo
echo "Finished chroot part"
echo "======================================"
cd ~/livecdtmp
sudo umount edit/dev

#Compress osgeolive build logs
#tar czf osgeo-live-${VERSION}-log.tar.gz -C edit/var/log osgeolive

echo
echo "Remastering the dvd..."
echo "======================================"
#Remaster the dvd

#Method 1 requires that dist-upgrade is run on both the host and chroot
#need to make sure modules.dep exists for the current kernel before next step
#sudo depmod
#sudo chroot edit depmod
#sudo chroot edit mkinitramfs -c lzma -o /initrd.lz

#Method 2 hardcode default kernel from Lubuntu
#need to repack the initrd.lz to pick up the change to casper.conf and kernel update
sudo chroot edit mkinitramfs -c lzma -o /initrd 4.18.0-15-generic
offset=$(binwalk ./edit/initrd -y lzma | grep 'LZMA' | awk '{ print $1; }')
dd if=./edit/initrd bs=$offset skip=1 > initrd.lz
dd if=./edit/initrd bs=1 count=$offset > initrd.micro
rm edit/initrd

#continue
mkdir lzfiles
cd lzfiles
lzma -dc -S .lz ../initrd.lz | cpio -imvd --no-absolute-filenames

#Perhaps not needed since this also happens in chroot part.
cp ../../gisvm/desktop-conf/casper/casper.conf etc/casper.conf
#cp ../../gisvm/desktop-conf/casper/27osgeo_groups scripts/casper-bottom/27osgeo_groups
#cat << EOF >> scripts/casper-bottom/ORDER
#/scripts/casper-bottom/27osgeo_groups
#[ -e /conf/param.conf ] && ./conf/param.conf
#EOF

mv scripts/casper-bottom/25adduser scripts/casper-bottom/25adduser.ORIG
cat scripts/casper-bottom/25adduser.ORIG \
    ../../gisvm/desktop-conf/casper/27osgeo_groups \
  > scripts/casper-bottom/25adduser
rm scripts/casper-bottom/25adduser.ORIG
chmod a+x scripts/casper-bottom/25adduser


#Replace the user password
sed -i -e 's/U6aMy0wojraho/eLyJdzDtonrIc/g' scripts/casper-bottom/25adduser

#Change the graphics on the lubuntu-logo plymouth loader both on lzfiles
# and on edit folders
cp ../../gisvm/desktop-conf/plymouth/lubuntu-logo/* \
    usr/share/plymouth/themes/lubuntu-logo/

cp ../../gisvm/desktop-conf/plymouth/lubuntu-logo/* \
    ../edit/usr/share/plymouth/themes/lubuntu-logo/

#Change the text on the lubuntu-text plymouth loader both on lzfiles
# and on edit folders
sed -i -e "s/title=.ubuntu ${UBU_RELEASE}/title=OSGeoLive ${VERSION_MODE}/g" \
    usr/share/plymouth/themes/lubuntu-text/lubuntu-text.plymouth

sed -i -e "s/title=.ubuntu ${UBU_RELEASE}/title=OSGeoLive ${VERSION_MODE}/g" \
    ../edit/usr/share/plymouth/themes/lubuntu-text/lubuntu-text.plymouth

#Optional change it in the .disk/info too
sed -i -e "s/.ubuntu ${ISO_RELEASE} LTS \"Bionic Beaver\"/OSGeoLive ${VERSION_MODE}/g" \
    ../extract-cd/.disk/info

rm ../initrd.lz
find . | cpio --quiet --dereference -o -H newc | \
   lzma -7 > ../initrd.lz

cd ..
cat initrd.micro initrd.lz > initrd
rm initrd.micro initrd.lz
mv initrd extract-cd/casper/initrd


echo
echo "Regenerating manifest..."
echo "======================================"

#Regenerate manifest 
chmod +w extract-cd/casper/filesystem.manifest
sudo chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > \
   extract-cd/casper/filesystem.manifest
sudo cp extract-cd/casper/filesystem.manifest \
   extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' \
   extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' \
   extract-cd/casper/filesystem.manifest-desktop

echo
echo "Compressing filesystem..."
echo "======================================"
#Compress filesystem
sudo rm extract-cd/casper/filesystem.squashfs
sudo mksquashfs edit extract-cd/casper/filesystem.squashfs
# sudo mksquashfs edit extract-cd/casper/filesystem.squashfs -no-progress

echo
echo "Calculating new filesystem size..."
echo "======================================"
#Update the filesystem.size file, which is needed by the installer:
# TODO: get it to run as sudo no sudo su
chmod +w extract-cd/casper/filesystem.size
printf $(sudo du -sx --block-size=1 edit | cut -f1) > \
   extract-cd/casper/filesystem.size
chmod -w extract-cd/casper/filesystem.size

#this is now compressed in squashfs so we delete to save VM disk space
cd ~/livecdtmp
sudo rm -rf edit

#Set an image name in extract-cd/README.diskdefines
cp "$GIT_DIR/desktop-conf/casper/README.diskdefines" extract-cd/README.diskdefines

echo
echo "Calculating new md5 sums..."
echo "======================================"
#Remove old md5sum.txt and calculate new md5 sums
cd extract-cd
sudo rm md5sum.txt
find -type f -print0 | sudo xargs -0 md5sum | \
   grep -v isolinux/boot.cat | sudo tee md5sum.txt

echo
echo "Creating iso..."
echo "======================================"
#Create the ISO image
#isohybrid used only in 64bit architecture
if [ "$ARCH" = "amd64" ] ; then
   sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -quiet -b \
      isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
      -boot-load-size 4 -boot-info-table \
      -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
      -o ../"$ISO_NAME.iso" .
   sudo isohybrid -u ../"$ISO_NAME.iso"
else
   sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -quiet -b \
      isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
      -boot-load-size 4 -boot-info-table -o ../"$ISO_NAME.iso" .
   sudo isohybrid ../"$ISO_NAME.iso"
fi

echo
echo "Cleaning up..."
echo "======================================"
#Clear things up and prepare for next build
cd ~/livecdtmp
sudo rm -rf extract-cd
sudo umount mnt
sudo rm -rf mnt
sudo rm -rf lzfiles

echo
echo "==============================================================="
echo "Finished building $ISO_NAME"
echo "==============================================================="
