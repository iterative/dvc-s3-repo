#!/bin/bash

set -e
set -x

DIR=$(dirname "${BASH_SOURCE[0]}")
source $DIR/../env.sh

PKG="../*.rpm"
RPM_REPO=$DIR/dvc.repo
ASC=$DIR/../iterative.asc
AWS_S3_PREFIX=dvc-pkgs/rpm
RPM_S3_DIR=$DIR/rpm-s3

echo "$GPG_ITERATIVE_PASS" > ~/iterative.pass
cp $DIR/rpmmacros ~/.rpmmacros

upload_file $RPM_REPO $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX
upload_file $ASC $AWS_S3_PREFIX/gpg

echo "$GPG_ITERATIVE_ASC" > Iterative.secret.asc
gpg2 --no-tty --batch --passphrase-file ~/iterative.pass --pinentry-mode loopback --import Iterative.secret.asc

rm -rf $RPM_S3_DIR
git clone https://github.com/iterative/rpm-s3 $RPM_S3_DIR --recurse-submodules

rpm --resign $PKG

export AWS_ACCESS_KEY=$(printenv AWS_ACCESS_KEY_ID)
export AWS_SECRET_KEY=$(printenv AWS_SECRET_ACCESS_KEY)
$RPM_S3_DIR/bin/rpm-s3 -vvv \
  --bucket $AWS_S3_BUCKET \
  --repopath $AWS_S3_PREFIX \
  --region $(printenv AWS_DEFAULT_REGION) \
  --keep 100 \
  --sign \
  --gpg-bin gpg2 \
  --gpg-options="--no-tty --batch --passphrase $GPG_ITERATIVE_PASS  --pinentry-mode loopback" \
  $PKG

cp $RPM_REPO /etc/yum.repos.d/
rpm --import $ASC
dnf update --verbose
dnf install -y dvc
