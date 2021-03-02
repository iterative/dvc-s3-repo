FROM fedora:26
RUN dnf update -y && \
    dnf install -y python-pip wget libffi-devel python-devel gcc git jq yum-utils python-deltarpm gnupg && \
    pip install --upgrade pip && \
    pip install boto awscli
