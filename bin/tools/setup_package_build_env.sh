#!/bin/sh

BASEDIST=noble

# TODO: find closest mirror from https://launchpad.net/ubuntu/+archivemirrors
MIRROR=${MIRROR-http://nl.archive.ubuntu.com/ubuntu/}

sudo cowbuilder --create \
                --distribution=${BASEDIST} \
                --basepath=/var/cache/pbuilder/base-${BASEDIST}-osgeolive.cow \
                --hookdir=/var/cache/pbuilder/hook.d/ \
                --mirror=${MIRROR} \
                --othermirror="deb [ trusted=yes ] http://ppa.launchpad.net/osgeolive/nightly/ubuntu ${BASEDIST} main" \
                --components="main universe"

