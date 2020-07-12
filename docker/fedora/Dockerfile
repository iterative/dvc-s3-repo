FROM fedora:32
RUN dnf update -y && \
    dnf install -y python-pip wget libffi-devel python-devel gcc git jq yum-utils python-deltarpm which && \
    pip install --upgrade pip && \
    pip install boto awscli
RUN alternatives --install /usr/bin/python python $(which python3) 10
