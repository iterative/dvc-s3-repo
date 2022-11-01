ARG PYTHON_VERSION=3.10.8
ARG RUBY_VERSION=2.6.9

FROM centos:7 as pyenv
ARG PYTHON_VERSION

ENV LC_ALL=en_US.UTF-8
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8

RUN yum install epel-release
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN yum install -y \
        curl \
        wget \
        git \
        make \
        bzip2 \
        bzip2-devel \
        gcc \
        libffi-devel \
        openssl11 \
        openssl11-libs \
        openssl11-devel \
        readline-devel \
        sqlite \
        sqlite-devel \
        tk-devel \
        xz-devel \
        zlib-devel

RUN curl https://pyenv.run | bash

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

RUN PYTHON_CONFIGURE_OPTS="--enable-shared" CPPFLAGS=$(pkg-config --cflags openssl11) LDFLAGS=$(pkg-config --libs openssl11) ~/.pyenv/bin/pyenv install ${PYTHON_VERSION}
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
RUN yum -y install yum-plugin-priorities
RUN sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

RUN yum -y install epel-release
RUN sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo

RUN yum -y install centos-release-scl-rh centos-release-scl
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

RUN gem install fpm

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]


# NOTE: uploading with rpm-s3 requires python2
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
        pip install boto awscli
