#!/bin/bash

set -e
set -x

AWS_S3_BUCKET=dvc-s3-repo
AWS_PROFILE=iterative

rm -f latest-version
wget https://updater.dvc.org -O latest-version

function get_pkg {
    URL=$(jq -r .packages.linux.$1 latest-version)
    PKG=$(basename $URL)
    rm -f $PKG
    wget $URL &> wget.log
    echo $(pwd)/$PKG
}

function get_conf {
    aws configure get --profile $AWS_PROFILE $1
}

function upload_file {
    aws s3 cp $1 s3://$AWS_S3_BUCKET/$2/ --profile $AWS_PROFILE --acl public-read
}
