[![Build Status](https://travis-ci.com/iterative/dvc-s3-repo.svg?branch=master)](https://travis-ci.com/iterative/dvc-s3-repo)
# dvc-s3-repo
Maintain deb and rpm repositories on s3

## Ubuntu, Debian
Install dvc from dep repository:
```
$ sudo cp deb/dvc.list /etc/apt/sources.list.d/
$ sudo apt-key add iterative.asc
$ sudo apt-get update
$ sudo apt-get install dvc
```

## Fedora, Centos, RHEL
Install dvc from rpm repository:
```
$ sudo cp rpm/dvc.repo /etc/yum.repos.d/
$ sudo dnf update
$ sudo dnf install dvc
```
