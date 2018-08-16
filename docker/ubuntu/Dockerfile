FROM ubuntu:16.04
RUN apt-get update && \
    apt-get install -y python-pip wget libffi-dev git jq rubygems apt-transport-https && \
    pip install --upgrade pip && \
    gem install deb-s3
