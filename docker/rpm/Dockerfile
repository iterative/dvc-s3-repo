ARG PYTHON_VERSION=3.8.3

FROM centos:7 as pyenv
ARG PYTHON_VERSION

ENV LC_ALL=en_US.UTF-8
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8

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
        openssl-devel \
        readline-devel \
        sqlite \
        sqlite-devel \
        tk-devel \
        xz-devel \
        zlib-devel

RUN curl https://pyenv.run | bash

ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

RUN PYTHON_CONFIGURE_OPTS="--enable-shared" ~/.pyenv/bin/pyenv install ${PYTHON_VERSION}
RUN pyenv global ${PYTHON_VERSION}

RUN test "${PYTHON_VERSION}" = "$(python --version | awk '{print $2}')"

FROM pyenv as builder

RUN pip --no-cache install -U pip wheel

# TODO: check if all of these dependencies are required
RUN yum install -y wget jq yum-utils gnupg make patch gdbm-devel ncurses-devel rpm-build
RUN yum -y install yum-plugin-priorities
RUN sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

RUN yum -y install epel-release
RUN sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo

RUN yum -y install centos-release-scl-rh centos-release-scl
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

RUN yum install -y rh-ruby23
RUN scl enable rh-ruby23 'gem install fpm'

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]

FROM builder as uploader
RUN yum install -y gnupg rpm-sign && \
    pip install boto awscli
