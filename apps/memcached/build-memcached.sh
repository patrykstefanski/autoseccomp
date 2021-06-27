#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly FILENAME="memcached-1.6.9.tar.gz"
readonly URL="http://www.memcached.org/files/$FILENAME"
readonly SHA256="d5a62ce377314dbffdb37c4467e7763e3abae376a16171e613cbe69956f092d1"

curl -s -L "$URL" | tee "$FILENAME" | sha256sum -c <(echo "$SHA256  -")
mkdir memcached
tar -C memcached -xvf "$FILENAME" --strip 1
cd memcached

patch -Np1 -i ../memcached.patch

declare -xr PATH="$DIR/../../scripts:$PATH"
declare -xr CC=autoseccomp-clang
autoreconf --verbose --install --force
./configure --disable-coverage --disable-docs --with-libevent="$PWD/../libevent/install"
make -j "$(nproc)"
