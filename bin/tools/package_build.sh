#!/bin/sh

# TODO: allow overriding via env variable
BASEDIST=noble

# Check you're in a git repository of a debian packaging project (how?)
which git > /dev/null || {
  echo "👎 this script needs 'git' to be installed" >&2
  exit 1
}

GIT_TOPLEVEL=$(git rev-parse --show-toplevel) || exit 1
test ${PWD} = "${GIT_TOPLEVEL}" || {
  echo "👎 This script needs to be run in the root path of a git repository" >&2
  exit 1
}

if [ "$(git remote -v | grep -c salsa.debian.org)" != 0 ]; then
  echo "👍 We are in the top-level dir of a git repository having Debian Salsa remote"
else
  echo "👎 The git repository needs to have a 'salsa.debian.org' remote" >&2
  exit 1
fi

gbp buildpackage --git-pbuilder --git-dist=${BASEDIST}-osgeolive
