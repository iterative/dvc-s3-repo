#!/bin/bash

set -e
set -x

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set."
  exit 1
fi

if [ -z "$AWS_S3_PREFIX" ]; then
  echo "AWS_S3_PREFIX is not set."
  exit 1
fi

PKG="../*.deb"
DEB_LIST=$DIR/dvc.list
ASC=$DIR/../iterative.asc

aws s3 cp $DEB_LIST s3://$AWS_S3_BUCKET/$AWS_S3_PREFIX/
aws s3 cp $ASC s3://$AWS_S3_BUCKET/$AWS_S3_PREFIX/
aws s3 cp $ASC s3://$AWS_S3_BUCKET/$AWS_S3_PREFIX/gpg/

echo "$GPG_ITERATIVE_ASC" > Iterative.secret.asc
gpg --no-tty --batch --passphrase $GPG_ITERATIVE_PASS --pinentry-mode loopback --import Iterative.secret.asc

gpg --list-keys

KEYID=$(gpg --list-secret-keys --with-colons | awk -F: '/^fpr:/ { print $10; exit }')

deb-s3 upload --bucket $AWS_S3_BUCKET \
  --prefix $AWS_S3_PREFIX \
  --preserve-versions \
  --arch amd64 \
  --codename stable \
  --visibility bucket_owner \
  --sign "${KEYID}" \
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
