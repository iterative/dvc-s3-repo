#!/bin/bash

set -e
set -x

function deploy {
    docker build -t dvc docker/$1
    docker run -v ~/.aws:/root/.aws -v $(pwd):/dvc -w /dvc/$2 --rm -t dvc ./upload.sh
}

deploy ubuntu deb
deploy fedora rpm
