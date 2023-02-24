[![Build Status](https://travis-ci.com/iterative/dvc-s3-repo.svg?branch=master)](https://travis-ci.com/iterative/dvc-s3-repo)
# dvc-s3-repo
Maintain deb and rpm repositories on s3

## Ubuntu, Debian
Install dvc from dep repository:
```
$ sudo wget \
       https://dvc.org/deb/dvc.list \
       -O /etc/apt/sources.list.d/dvc.list
$ wget -qO - https://dvc.org/deb/iterative.asc | gpg --dearmor > packages.iterative.gpg
$ sudo install -o root -g root -m 644 packages.iterative.gpg /etc/apt/trusted.gpg.d/
$ rm -f packages.iterative.gpg
$ sudo apt update
$ sudo apt install dvc
```

## Fedora, Centos, RHEL
Install dvc from rpm repository:
```
$ sudo wget \
       https://dvc.org/rpm/dvc.repo \
       -O /etc/yum.repos.d/dvc.repo
$ sudo rpm --import https://dvc.org/rpm/iterative.asc
$ sudo yum update
$ sudo yum install dvc
```
