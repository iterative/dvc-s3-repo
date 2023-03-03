#!/bin/bash

set -e

PASSWD=$(gpg --gen-random --armor 1 14)
export GNUPGHOME="$(mktemp -d)"

gpg --passphrase "$PASSWD" \
    --pinentry-mode loopback \
    --quick-generate-key "Iterative <eng@iterative.ai>" rsa4096 sign 2y

gpg --list-keys

gpg --armor --export Iterative > iterative.asc

gpg --armor \
    --passphrase "$PASSWD" \
    --pinentry-mode loopback \
    --export-secret-keys Iterative

echo "Save secret key ^ and its passphrase $PASSWD in a secure location"
