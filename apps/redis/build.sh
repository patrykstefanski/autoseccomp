#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly FILENAME="redis-6.2.3.tar.gz"
readonly URL="https://download.redis.io/releases/$FILENAME"
readonly SHA256="98ed7d532b5e9671f5df0825bb71f0f37483a16546364049384c63db8764512b"

curl -s -L "$URL" | tee "$FILENAME" | sha256sum -c <(echo "$SHA256  -")
mkdir redis
tar -C redis -xvf "$FILENAME" --strip 1
cd redis

patch -Np1 -i ../redis.patch

declare -xr PATH="$DIR/../../scripts:$PATH"
declare -xr CC=autoseccomp-clang
declare -xr USE_SYSTEMD=no
make -j "$(nproc)"
