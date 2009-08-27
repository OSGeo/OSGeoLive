 #!/bin/sh
 cd /usr/lib
 wget http://udig.refractions.net/files/downloads/branches/udig-1.2-M6.linux.gtk.x86.tar.gz
 tar -xzf udig-1.2-M6.linux.gtk.x86.tar
 
 rm udig-1.2-M6.linux.gtk.x86.tar
 
 #In udig.sh replace ./udig_internals with
 #DATA_ARG=false
 #
 #for ARG in $@ 
 #do
 #        if [ $ARG = "-data" ]; then DATA_ARG=true; fi
 #done
 #
 #if $DATA_ARG; then 
 #        /usr/lib/udig/udig_internal $@
 #else
 #        /usr/lib/udig/udig_internal -data $HOME/uDigWorkspace $@
 #fi
 mkdir /tmp/udig_downloads/udig-data
 cd /tmp/udig_downloads/udig-data
 wget http://udig.refractions.net/docs/data-v1_1.zip
 unzip data-v1_1.zip
 rm data-v1_1.zip
 mv -rf /tmp/udig_downloads/udig-data /usr/local/share
 rm -rf /tmp/udig_downloads
 
