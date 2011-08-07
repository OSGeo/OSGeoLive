#!/bin/sh
#Must be run as sudo
#Needs to be run after vm build is done and has been rebooted
cat /dev/zero > zero.fill ; sync ; sleep 1 ; sync ; rm -f zero.fill
