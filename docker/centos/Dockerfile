FROM centos:7
RUN yum install -y wget libffi-devel jq yum-utils gnupg gcc make patch gdbm-devel openssl-devel sqlite-devel readline-devel zlib-devel bzip2-devel ncurses-devel
RUN yum -y install yum-plugin-priorities
RUN sed -i -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo
RUN yum -y install epel-release
RUN sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo
RUN yum -y install centos-release-scl-rh centos-release-scl
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
RUN sed -i -e "s/\]$/\]\npriority=10/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo
RUN yum install -y rh-ruby23 git
RUN curl https://pyenv.run | bash
RUN PYTHON_CONFIGURE_OPTS="--enable-shared" ~/.pyenv/bin/pyenv install 3.8.3
RUN scl enable rh-ruby23 'gem install fpm'
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN locale
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
