#!/bin/sh

# TODO: allow overriding via env variable
BASEDIST=noble

# TODO: check you're in a git repository of a debian packaging project (how?)

gbp buildpackage --git-pbuilder --git-dist=${BASEDIST}-osgeolive
