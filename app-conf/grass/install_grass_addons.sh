#!/bin/sh
############################################################################
#
# PROGRAM:      install_grass_addons.sh
# AUTHOR(S):    M. Hamish Bowman, Dunedin, New Zealand
# PURPOSE:      Installs a selection of GRASS addon modules via g.extension
# COPYRIGHT:    (C) 2014 Hamish Bowman, and the GRASS Development Team
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
############################################################################


if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program." >&2
    exit 1
fi


ADDONS="
r.basin
r.ipso
r.stream.angle
r.stream.basins
r.stream.del
r.stream.distance
r.stream.extract
r.stream.order
r.stream.pos
r.stream.preview
r.stream.stats
r.surf.nnbathy
r.surf.volcano
r.wf
v.autokrige
"

GRASS_ADDON_PATH=/usr/local/share/grass/addons
export GRASS_ADDON_PATH


for ADDON in $ADDONS ; do
   g.extension "$ADDON"
done

