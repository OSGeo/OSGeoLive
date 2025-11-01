#!/bin/sh

# TODO: allow overriding via env variable
BASEDIST=noble

# TODO: find closest mirror from https://launchpad.net/ubuntu/+archivemirrors
MIRROR=${MIRROR-http://nl.archive.ubuntu.com/ubuntu/}

# Make sure the required tools are installed
apt install \
  ubuntu-keyring \
  cowbuilder

BASEPATH="/var/cache/pbuilder/base-${BASEDIST}-osgeolive.cow"

if test -e "${BASEPATH}"; then
  # Update the chroot
  cowbuilder --update \
             --basepath="${BASEPATH}"
else
  # Create the chroot
  cowbuilder --create \
             --distribution=${BASEDIST} \
             --basepath="${BASEPATH}" \
             --hookdir=/var/cache/pbuilder/hook.d/ \
             --mirror="${MIRROR}" \
             --othermirror="deb [ trusted=yes ] http://ppa.launchpad.net/osgeolive/nightly/ubuntu ${BASEDIST} main" \
             --components="main universe"
fi

