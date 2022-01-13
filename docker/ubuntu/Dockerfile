FROM ubuntu:20.04 as base
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python-is-python3 python3-pip wget libffi-dev git jq rubygems apt-transport-https && \
    gem install fpm && \
    rm -rf /var/lib/apt/lists/*
    # TODO: maybe move build deps such as fpm away from here



FROM base as upload

RUN pip --no-cache-dir install boto awscli && \
    gem install deb-s3
