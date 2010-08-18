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
