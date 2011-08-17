#!/bin/sh
#  Check if gosmore processed file exists, if not offer to make it
#  (c) H.Bowman 17 March 2011
#  license: LGPL >= 2.1

if [ -e ~/gosmore.pak ] ; then
   exec gosmore
fi


# else


gxmessage -buttons "Generate,Cancel" -default "Generate" \
  '"gosmore.pak" does not exist. Do you want to generate it now?'

# echo $?
# 101  1st button 
# 102  2nd button

if [ $? -eq 101 ] ; then
   cd
   gxmessage -timeout 10 \
      'Building "gosmore.pak", please wait ...' &

   nice bzip2 -dc /usr/local/share/data/osm/feature_city.osm.bz2 | \
      nice gosmore rebuild
else
   exec gosmore
fi

