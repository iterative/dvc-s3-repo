#!/bin/bash

set -e
set -x

AWS_S3_BUCKET="${AWS_S3_BUCKET:=dvc-public}"

function upload_file {
  aws s3 cp $1 s3://$AWS_S3_BUCKET/$2/
}
