#!/bin/sh

set -e

PROJECT="iterative/dvc"
GHAPI_URL="https://api.github.com/repos/$PROJECT/releases/latest"
echo $(curl --silent $GHAPI_URL | jq -r .tag_name)
