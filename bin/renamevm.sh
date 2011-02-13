#!/bin/sh
#Copy a vmware image to a new name
#needs to be run as sudo
#Command line args, original dir, new dir
orig=$1
new=$2
cp -R $1 $2
cd $2
#Quick way to rename the files
mv ${orig}.vmx ${new}.vmx
mv ${orig}.vmdk ${new}.vmdk
mv ${orig}.vmxf ${new}.vmxf
mv ${orig}.vmsd ${new}.vmsd
mv ${orig}.nvram ${new}.nvram

#replace names in vmx file to link to the new names
sed -i "s/${orig}/${new}/g" ${new}.vmx
