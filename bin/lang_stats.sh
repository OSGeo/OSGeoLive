#!/bin/sh
############################################################################
#
# TOOL:         lang_stats.sh
# AUTHOR:       M. Hamish Bowman, Dunedin, New Zealand
# PURPOSE:      Runs through the OSGeo Live DVD translations and makes a
#		ranking table.
# COPYRIGHT:    (c) 2012 Hamish Bowman, and the OSGeo Foundation
#               This program is free software under the GNU General Public
#               License (>=v2). Read the file COPYING that comes with GRASS
#               for details.
#
#############################################################################

#assumes you're already in the gisvm/trunk/bin/ or doc/ dir
TOPDIR=`pwd | sed -e 's+.*/++'`
if [ "$TOPDIR" = "bin" ] ; then
  cd ../doc/
elif [ "$TOPDIR" = "doc" ] ; then
   :
else
   echo "help, I'm lost"
   exit 1
fi


NUM_PAGES=`ls -1 *.rst en/*.rst en/*.txt en/*/*.rst | wc -l`

# pages with no text to translate
NO_CONTENT=3

NUM_PAGES=`expr $NUM_PAGES - $NO_CONTENT`

LANGS="ca de el es it ja pl zh"

cat << EOF > lang_stats.html
<html>
<head>
<title>OSGeo Live Demo DVD Translation Stats</title>
</head>
<body>

<br><br><br><br>
<center>
<h2>OSGeo Live Translation Stats</h2>
Help translate -
  <a href="http://wiki.osgeo.org/wiki/Live_GIS_Translate">click here!</a>
<br>
<br>
<table border="1">
  <tr>
    <td>Language</td>
    <td>Code</td>
    <td align="center">Docs<br>translated</td>
    <td>To do</td>
    <td align="center">Percent<br>complete</td>
  </tr>
  <tr>
    <td><i>English</i></td>
    <td><i>en</i></td>
    <td align="right"><i>$NUM_PAGES</i></td>
    <td align="right"><i>0</i></td>
    <td align="right"><i>100.0</i></td>
  </tr>
EOF

rm -f lang_stats.prn
for CODE in $LANGS ; do
   DONE=`ls -1 *.rst $CODE/*.rst $CODE/*.txt $CODE/*/*.rst | wc -l`
   LEFT=`expr $NUM_PAGES - $DONE`
   PERCENT=`echo "$DONE $NUM_PAGES" | awk '{printf("%.1f", $1 * 100.0 / $2)}'`
   
   case "$CODE" in
     ca) LAN=Catalan
         ;;
     de) LAN=German
         ;;
     el) LAN=Greek
         ;;
     es) LAN=Spanish
         ;;
     it) LAN=Italian
         ;;
     ja) LAN=Japanese
         ;;
     pl) LAN=Polish
         ;;
     zh) LAN=Chinese
         ;;
     *) echo "an error occurred."
   esac

   echo "$LAN,$CODE,$DONE,$LEFT,$PERCENT" >> lang_stats.prn
done

# late to the party
echo "French,fr,0,$NUM_PAGES,0.0" >> lang_stats.prn

sort -k3 -t, -nr lang_stats.prn > lang_stats_sorted.prn

rm -f lang_stats.prn

while read line ; do
    echo "$line" | awk -F, '{print " ",
       " <tr>\n    <td>",$1,
       "</td>\n    <td>",$2,
       "</td>\n    <td align=\"right\">",$3,
       "</td>\n    <td align=\"right\">",$4,
       "</td>\n    <td align=\"right\">",$5,
       "</td>\n  </tr>"}' >> lang_stats.html
done < lang_stats_sorted.prn


cat << EOF >> lang_stats.html
</table>
<br>
<font size="-2">
<i>Valid as of `date`</i>
</font>
</center>
</body>
</html>
EOF

rm -f lang_stats_sorted.prn


#cp lang_stats.html /where/it/needs/to/go/

