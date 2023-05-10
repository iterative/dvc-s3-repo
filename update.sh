#!/bin/sh

set -e
set -x

LATEST=$1
if [ ! $LATEST ]; then
  LATEST=$(./latest.sh)
fi

sed -i 's/^VERSION = .*$/VERSION = '"\"$LATEST\""'/g' download.py
