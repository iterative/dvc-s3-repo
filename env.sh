#!/bin/bash

set -e
set -x

AWS_S3_BUCKET=dvc-s3-repo
AWS_PROFILE=iterative

RPM_PKG="dvc-$VERSION-1.x86_64.rpm"
DEB_PKG="dvc_""$VERSION""_amd64.deb"

function get_conf {
  aws configure get --profile $AWS_PROFILE $1
}

function upload_file {
  aws s3 cp $1 s3://$AWS_S3_BUCKET/$2/ --profile $AWS_PROFILE --acl public-read
}
