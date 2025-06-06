ARG PYTHON_VERSION=3.12.7
ARG RUBY_VERSION=2.6.9

FROM fedora:35 as pyenv
ARG PYTHON_VERSION

# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
# https://github.com/pyenv/pyenv/issues/2416
RUN yum install -y \
        curl \
        wget \
        git \
        make \
        bzip2 \
        bzip2-devel \
        gcc \
        libffi-devel \
        openssl-devel \
        readline-devel \
        sqlite \
        sqlite-devel \
        tk-devel \
        xz-devel \
        zlib-devel \
        findutils

RUN curl https://pyenv.run | bash

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

RUN PYTHON_CONFIGURE_OPTS="--enable-shared" ~/.pyenv/bin/pyenv install ${PYTHON_VERSION}
RUN pyenv global ${PYTHON_VERSION}

RUN test "${PYTHON_VERSION}" = "$(python --version | awk '{print $2}')"

FROM pyenv as rbenv
ARG RUBY_VERSION

RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
ENV RBENV_ROOT="/root/.rbenv"
ENV PATH="$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH"
RUN rbenv install ${RUBY_VERSION}
RUN rbenv global ${RUBY_VERSION}
RUN ruby --version | grep ${RUBY_VERSION}

FROM rbenv as builder

RUN pip --no-cache install -U pip wheel

# TODO: check if all of these dependencies are required
RUN yum install -y wget jq yum-utils gnupg patch gdbm-devel ncurses-devel rpm-build

RUN gem install dotenv -v 2.8.1
RUN gem install fpm

# NOTE: uploading with rpm-s3 requires python2, so we need to keep using fedora:26
FROM fedora:26 as uploader
RUN dnf update -y && \
        dnf install -y python-pip \
            wget \
            libffi-devel \
            python-devel \
            gcc \
            git \
            jq \
            yum-utils \
            python-deltarpm \
            gnupg rpm-sign && \
        pip install --upgrade pip && \
        pip install boto awscli python-dateutil==2.8.2
