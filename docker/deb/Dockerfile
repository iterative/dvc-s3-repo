ARG PYTHON_VERSION=3.12
ARG RUBY_VERSION=2.6.9

FROM ubuntu:20.04 as pyenv
ARG PYTHON_VERSION


# Setup python (pyenv) build dependencies (https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
RUN apt-get update && \
   DEBIAN_FRONTEND=noninteractive  apt-get install -y \
        build-essential \
        git \
        curl \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libxmlsec1-dev \
        llvm \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://pyenv.run | bash

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

RUN PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install ${PYTHON_VERSION}
RUN pyenv global ${PYTHON_VERSION}

# make sure we're using the correct python version
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

RUN apt-get update && \
    apt-get install -y jq apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

RUN gem install dotenv -v 2.8.1
RUN gem install fpm

RUN pip --no-cache-dir install -U pip wheel

FROM builder as uploader

RUN pip --no-cache-dir install boto awscli && \
    gem install deb-s3 -v 0.10.0
