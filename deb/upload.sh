#!/bin/bash

set -e
set -x

DIR=$(dirname "${BASH_SOURCE[0]}")
source $DIR/../env.sh

PKG=$(get_pkg deb)
DEB_LIST=$DIR/dvc.list
AWS_S3_PREFIX=deb

KEYNAME=dvc-s3-repo
EMAIL=eng@iterative.ai
export GNUPGHOME=$(pwd)/gnupg

rm -rf $GNUPGHOME
mkdir $GNUPGHOME
echo "cert-digest-algo SHA256" > $GNUPGHOME/gpg.conf
echo "digest-algo SHA256" > $GNUPGHOME/gpg.conf

cat > $KEYNAME.batch <<EOF
 %echo Generating a standard key
  Key-Type: RSA
   Key-Length: 4096
    Subkey-Length: 4096
     Name-Real: dvc-s3-repo
 Name-Email: eng@iterative.ai
 Expire-Date: 0
 %no-protection
 # Do a commit here, so that we can later print "done" :-)
 %commit
 %echo done
EOF

gpg --batch --gen-key $KEYNAME.batch
KEYID=$(gpg --list-secret-keys --with-colons | grep '^sec:' | cut --delimiter ':' --fields 5)

upload_file $DEB_LIST $AWS_S3_PREFIX

deb-s3 upload --bucket $AWS_S3_BUCKET \
              --prefix $AWS_S3_PREFIX \
              --preserve-versions \
              --arch amd64 \
              --codename stable \
              --sign=$KEYID \
              --access-key-id $(get_conf aws_access_key_id) \
              --secret-access-key $(get_conf aws_secret_access_key) \
              --s3-region $(get_conf region) \
              $PKG

cp $DEB_LIST /etc/apt/sources.list.d/
apt-get update
apt-get install dvc
dvc --help
