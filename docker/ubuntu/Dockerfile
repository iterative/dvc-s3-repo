FROM ubuntu:20.04
RUN apt-get update && \
    apt-get install -y python3-pip wget libffi-dev git jq rubygems apt-transport-https && \
    pip3 install boto awscli && \
    gem install deb-s3
