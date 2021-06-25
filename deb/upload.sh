#!/bin/bash

set -e
set -x

DIR=$(dirname "${BASH_SOURCE[0]}")
source $DIR/../env.sh

PKG="../*.deb"
DEB_LIST=$DIR/dvc.list
ASC=$DIR/../iterative.asc
AWS_S3_PREFIX=deb

upload_file $DEB_LIST $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX

echo "$GPG_ITERATIVE_ASC" > Iterative.asc
gpg --no-tty --batch --passphrase $GPG_ITERATIVE_PASS --pinentry-mode loopback --import Iterative.asc

deb-s3 upload --bucket $AWS_S3_BUCKET \
  --prefix $AWS_S3_PREFIX \
  --preserve-versions \
  --arch amd64 \
  --codename stable \
  --sign=$KEYID \
  --gpg-options="--no-tty --batch --passphrase $GPG_ITERATIVE_PASS  --pinentry-mode loopback" \
  --access-key-id $(get_conf aws_access_key_id) \
  --secret-access-key $(get_conf aws_secret_access_key) \
  --s3-region $(get_conf region) \
  $PKG

cp $DEB_LIST /etc/apt/sources.list.d/
apt-key add $ASC
apt-get update
apt-get install dvc
dvc --help
dvc doctor
apt-get remove -y dvc
