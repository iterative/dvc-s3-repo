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

mkdir ~/.gnupg
echo "cert-digest-algo SHA256" >> ~/.gnupg/gpg.conf
echo "digest-algo SHA256" >> ~/.gnupg/gpg.conf

cat > $KEYNAME.batch <<EOF
 %echo Generating a standard key
  Key-Type: RSA
   Key-Length: 4096
    Subkey-Length: 4096
     Name-Real: ${KEYNAME}
 Name-Email: ${EMAIL}
 Expire-Date: 0
 %pubring ${KEYNAME}.pub
 %secring ${KEYNAME}.key
 # Do a commit here, so that we can later print "done" :-)
 %commit
 %echo done
EOF

gpg --batch --gen-key $KEYNAME.batch
gpg --no-default-keyring --secret-keyring ${KEYNAME}.key --keyring ${KEYNAME}.pub --list-secret-keys
gpg --import ${KEYNAME}.key

upload_file $DEB_LIST $AWS_S3_PREFIX

deb-s3 upload --bucket $AWS_S3_BUCKET \
              --prefix $AWS_S3_PREFIX \
              --preserve-versions \
              --arch amd64 \
              --codename stable \
	      --sign=$(gpg ${KEYNAME}.key) \
              --access-key-id $(get_conf aws_access_key_id) \
              --secret-access-key $(get_conf aws_secret_access_key) \
              --s3-region $(get_conf region) \
              $PKG

cp $DEB_LIST /etc/apt/sources.list.d/
apt-get update
apt-get install dvc
dvc --help
