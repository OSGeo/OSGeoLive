#!/bin/sh
#############################################################################
# 
# Purpose: udig launcher
#
#############################################################################
# Copyright (c) 2010-2018 Open Source Geospatial Foundation (OSGeo)
# Copyright (c) 2009 LISAsoft
#
# Licensed under the GNU LGPL version >= 2.1.
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

PWD=`pwd`
export GDAL_DATA="$PWD/gdal_data"

#!/bin/sh
PRG="$0"
while [ -h "$PRG" ]; do
        ls=`ls -ld "$PRG"`
        link=`expr "$ls" : '.*-> \(.*\)$'`
        if expr "$link" : '/.*' > /dev/null; then
                PRG="$link"
        else
                PRG=`dirname "$PRG"`/"$link"
        fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`
DATA_ARG=false

for ARG in $@ 
do
        if [ $ARG = "-data" ]; then DATA_ARG=true; fi
done

if $DATA_ARG; then 
        $PRGDIR/udig_internal $@
else
        $PRGDIR/udig_internal -data ~/uDigWorkspace $@
fi
