#!/bin/bash

set -e
set -x

AWS_S3_BUCKET=dvc-public

RPM_PKG="dvc-$VERSION-1.x86_64.rpm"
DEB_PKG="dvc_""$VERSION""_amd64.deb"

function upload_file {
  aws s3 cp $1 s3://$AWS_S3_BUCKET/$2/
}
