#!/bin/bash

set -e
set -x

DIR=$(dirname "${BASH_SOURCE[0]}")
source $DIR/../env.sh

PKG="../*.deb"
DEB_LIST=$DIR/dvc.list
ASC=$DIR/../iterative.asc
AWS_S3_PREFIX=dvc-pkgs/deb

upload_file $DEB_LIST $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX/gpg

echo "$GPG_ITERATIVE_ASC" > Iterative.secret.asc
gpg --no-tty --batch --passphrase $GPG_ITERATIVE_PASS --pinentry-mode loopback --import Iterative.secret.asc

gpg --list-keys

deb-s3 upload --bucket $AWS_S3_BUCKET \
  --prefix $AWS_S3_PREFIX \
  --preserve-versions \
  --arch amd64 \
  --codename stable \
  --visibility bucket_owner \
  --sign \
  --gpg-options="--no-tty --batch --passphrase $GPG_ITERATIVE_PASS  --pinentry-mode loopback" \
  --access-key-id $(printenv AWS_ACCESS_KEY_ID) \
  --secret-access-key $(printenv AWS_SECRET_ACCESS_KEY) \
  --session-token $(printenv AWS_SESSION_TOKEN) \
  --s3-region $(printenv AWS_DEFAULT_REGION) \
  $PKG

cp $DEB_LIST /etc/apt/sources.list.d/
apt-key add $ASC
apt-get update
apt-get install dvc
dvc --help
dvc doctor
apt-get remove -y dvc
