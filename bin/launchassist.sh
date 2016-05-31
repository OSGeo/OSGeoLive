#!/bin/sh/
#launchassist
#Takes script/app to launch as an arg an makes sure it's run as sudo.
#Seems to alleviate strange behavior of desktop icons not launching apps properly
PASSWORD=user
echo "Launching $1"
echo $PASSWORD | sudo -S $1
