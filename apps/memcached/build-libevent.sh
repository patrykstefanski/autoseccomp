#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly FILENAME="libevent-2.1.12-stable.tar.gz"
readonly URL="https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
readonly SHA256="92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb"

curl -s -L "$URL" | tee "$FILENAME" | sha256sum -c <(echo "$SHA256  -")
mkdir libevent
tar -C libevent -xvf "$FILENAME" --strip 1
cd libevent

declare -xr PATH="$DIR/../../scripts:$PATH"
declare -xr CC=autoseccomp-clang
./configure --prefix="$PWD/install" --disable-shared --disable-openssl
make -j "$(nproc)"
make install
