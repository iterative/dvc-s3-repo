#!/bin/bash

set -e
set -x

rm -f latest-version
wget https://4ki8820rsf.execute-api.us-east-2.amazonaws.com/prod/latest-version

URL=$(jq -r .packages.linux.deb latest-version)
DEB=$(basename $URL)

rm -f $DEB
wget $URL

deb-s3 upload --bucket dvc-deb \
              --preserve-versions \
              --arch amd64 \
              --codename stable \
              --s3-region us-east-2 \
              $DEB

cp dvc.list /etc/apt/sources.list.d/
apt-get update
apt-get install dvc
dvc --help
