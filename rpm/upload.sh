#!/bin/bash

set -e
set -x

rm -rf rpm-s3
git clone https://github.com/crohr/rpm-s3 --recurse-submodules

pushd rpm-s3

rm -f latest-version
wget https://4ki8820rsf.execute-api.us-east-2.amazonaws.com/prod/latest-version

URL=$(jq -r .packages.linux.rpm latest-version)
RPM=$(basename $URL)

rm -f $RPM
wget $URL

./bin/rpm-s3 --bucket dvc-rpm \
             --region us-east-2 \
             --keep 100 \
             --visibility public-read \
             $RPM
popd

cp dvc.repo /etc/yum.repos.d/
dnf update --verbose
dnf install -y dvc
dvc --help
