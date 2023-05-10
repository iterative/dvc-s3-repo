#!/bin/sh

set -e

PROJECT="iterative/dvc"
echo $(gh release list -R $PROJECT -L1 | awk -F '\t' '{ print $3 }')
