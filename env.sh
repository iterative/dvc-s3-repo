#!/bin/bash

set -e
set -x

VERSION="2.0.14"
BASE="https://github.com/iterative/dvc/releases/download/$VERSION"

AWS_S3_BUCKET=dvc-s3-repo
AWS_PROFILE=iterative

function get_pkg {
    if [ "$1" == "rpm" ]; then
        pkg="dvc-$VERSION-1.x86_64.rpm"
    elif [ "$1" == "deb" ]; then
        pkg="dvc_""$VERSION""_amd64.deb"
    fi

    rm -f $pkg
    wget "$BASE/$pkg" &> wget.log
    echo $(pwd)/$pkg
}

function get_conf {
    aws configure get --profile $AWS_PROFILE $1
}

function upload_file {
    aws s3 cp $1 s3://$AWS_S3_BUCKET/$2/ --profile $AWS_PROFILE --acl public-read
}
