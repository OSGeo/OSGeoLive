#!/bin/sh
# Copyright (c) 2009 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL v.2.1.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LGPL-2.1.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#
#
# script to install MB-System
#    written by H.Bowman <hamish_b  yahoo com>
#    MB-System homepage: http://www.ldeo.columbia.edu/res/pi/MB-System/
#



#!#!# EXPERIMENTAL #!#!#


MB_VERSION="5.1.2beta11"
LATEST="ftp://ftp.ldeo.columbia.edu/pub/MB-System/mbsystem-$MB_VERSION.tar.gz"

### FIXME: install size currently 319 MB. Need to figure out how to build it
###   using shared libraries.


#### get dependencies ####

DEPENDS="gmt gv xv lesstif2 libnetcdf4 libgl1-mesa-glx libglu1-mesa"
BUILD_DEPENDS="libgmt-dev lesstif2-dev libnetcdf-dev libglu1-mesa-dev libgl1-mesa-dev"
#make gcc, ...

PACKAGES="$DEPENDS $BUILD_DEPENDS"


TO_INSTALL=""
for PACKAGE in $PACKAGES ; do
   if [ `dpkg -l $PACKAGE | grep -c '^ii'` -eq 0 ] ; then
      TO_INSTALL="$TO_INSTALL $PACKAGE"
   fi
done

if [ -n "$TO_INSTALL" ] ; then
   apt-get --assume-yes install $TO_INSTALL

   if [ $? -ne 0 ] ; then
      echo "ERROR: package install failed: $TO_INSTALL"
      #exit 1
   fi
fi



mkdir -p /tmp/build_mbsystem
cd /tmp/build_mbsystem

#### get tarball ####

if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

wget -nv "$LATEST"

tar xzf `basename $LATEST`

if [ $? -eq 0 ] ; then
   \rm `basename $LATEST`
fi

cd `basename $LATEST .tar.gz`



#### create patches ####

echo '--- install_makefiles.ORIG      2009-08-27 23:53:46.000000000 +1200
+++ install_makefiles   2009-08-28 00:01:00.000000000 +1200
@@ -97,21 +97,21 @@
 #
 # Required parameters:
 $MBSYSTEM_HOME = "/usr/local/mbsystem";
-$OS = "DARWIN";
+$OS = "LINUX";
 $CFLAGS = "-g -I/usr/X11R6/include";
-$LFLAGS = "-Wl -lm -bind_at_load -Wl,-dylib_file,/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/LibGL.dylib";
-$NETCDFLIBDIR = "/sw/lib";
-$NETCDFINCDIR = "/sw/include";
-$GMTLIBDIR = "/usr/local/gmt/lib";
-$GMTINCDIR = "/usr/local/gmt/include";
+$LFLAGS = "-Wl -lm";
+$NETCDFLIBDIR = "/usr/lib";
+$NETCDFINCDIR = "/usr/include";
+$GMTLIBDIR = "/usr/lib";
+$GMTINCDIR = "/usr/include/gmt";
 $LEVITUS = "$MBSYSTEM_HOME/share/LevitusAnnual82.dat";
 $PROJECTIONS = "$MBSYSTEM_HOME/share/Projections.dat";
 #
 # Required paramters for graphical tools
 #   - graphical tools will not be built if these
 #     are commented out
-$MOTIFINCDIR = "/sw/include";
-$MOTIFLIBS = "-L/sw/lib -L/usr/X11R6/lib -lXm -lXt -lX11";
+$MOTIFINCDIR = "/usr/include";
+$MOTIFLIBS = "-L/usr/lib -L/usr/X11R6/lib -lXm -lXt -lX11";
 #
 # Required paramter for visualization tools
 #   - visualization tools will not be built if this' > \
  install_makefiles.Lenny.patch


echo '--- src/utilities/mbps.c.ORIG   2009-08-28 00:21:17.000000000 +1200
+++ src/utilities/mbps.c        2009-08-28 00:22:54.000000000 +1200
@@ -842,10 +842,17 @@
                }
                
        /* initialize the Postscript plotting */
+#ifdef GMT_MINOR_VERSION
        ps_plotinit_hires(NULL,0,orient,x_off,y_off,1.0,1.0,1,300,1,
                gmtdefs.paper_width, gmtdefs.page_rgb, 
                gmtdefs.encoding.name, 
                GMT_epsinfo (argv[0]));
+#else
+       ps_plotinit(NULL,0,orient,x_off,y_off,1.0,1.0,1,300,1,
+               gmtdefs.paper_width, gmtdefs.page_rgb, 
+               gmtdefs.encoding.name, 
+               GMT_epsinfo (argv[0]));
+#endif
        GMT_echo_command (argc, argv);
                
        /* now loop over the data in the appropriate order' > \
  mbps_c_gmt431.Lenny.patch



#### config build ####

# FIXME: what to set MBSYSTEM_HOME to in patch? build dir or destination dir?
patch -p0 < install_makefiles.Lenny.patch

#needed for 5.1.2beta11
patch -p0 < mbps_c_gmt431.Lenny.patch

./install_makefiles

make all


#### install ####
install bin/* /usr/local/bin
install --mode=644 lib/* /usr/local/lib
install --mode=644 man/manl/* /usr/local/man/manl
for SUBDIR in  html include ps share ; do
   mkdir -p /usr/local/mbsystem/$SUBDIR
   install --mode=644 $SUBDIR/* /usr/local/mbsystem/$SUBDIR
done



### cleanup ####
apt-get remove $BUILD_DEPENDS
#\rm install_makefiles.Lenny.patch mbps_c_gmt431.patch
cd ..
rm -rf `basename $LATEST .tar.gz`



# add /usr/local/lib to /etc/ld.so.conf if needed, then run ldconfig
# FIXME: similar thing needed for man pages?
# FIXME: not needed until we figure out how to make shared libs?
if [ -d /etc/ld.so.conf.d ] ; then
   echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local.conf
else
   if [ `grep -c '/usr/local/lib' /etc/ld.so.conf` -eq 0 ] ; then
      echo "/usr/local/lib" >> /etc/ld.so.conf
   fi
fi
ldconfig


#### user config ####
# FIXME: ~ here is root's home not user's home? what's the user's name?
if [ `grep -c 'PS_VIEWER=' ~/.bashrc` -eq 0 ] ; then
   echo "export PS_VIEWER=gv" >> ~/.bashrc
fi


echo "Finished installing MB System."

