#!/bin/bash

set -e
set -x

DIR=$(dirname "${BASH_SOURCE[0]}")
source $DIR/../env.sh

PKG=$(get_pkg rpm)
RPM_REPO=$DIR/dvc.repo
ASC=$DIR/../iterative.asc
AWS_S3_PREFIX=rpm
RPM_S3_DIR=$DIR/rpm-s3

cp $DIR/rpmmacros ~/.rpmmacros

upload_file $RPM_REPO $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX

echo "$GPG_ITERATIVE_ASC" > Iterative.asc
gpg --no-tty --batch --passphrase $GPG_ITERATIVE_PASS --pinentry-mode loopback --import Iterative.asc

rm -rf $RPM_S3_DIR
git clone https://github.com/crohr/rpm-s3 $RPM_S3_DIR --recurse-submodules

export AWS_ACCESS_KEY=$(get_conf aws_access_key_id)
export AWS_SECRET_KEY=$(get_conf aws_secret_access_key)
$RPM_S3_DIR/bin/rpm-s3 --bucket $AWS_S3_BUCKET \
                       --repopath $AWS_S3_PREFIX \
                       --region $(get_conf region) \
                       --keep 100 \
                       --visibility public-read \
                       --sign \
                       $PKG

cp $RPM_REPO /etc/yum.repos.d/
dnf update --verbose
dnf install -y dvc
dvc --help
