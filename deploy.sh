#!/bin/bash

set -e
set -x

function deploy {
    docker build -t dvc docker/$1
    docker run -e GPG_ITERATIVE_ASC -e GPG_ITERATIVE_PASS -v ~/.aws:/root/.aws -v $(pwd):/dvc -w /dvc/$2 --rm -t dvc ./upload.sh
}

if [[ -z "$@" ]]; then
    deploy ubuntu deb
    deploy fedora rpm
else
    deploy $@
fi
