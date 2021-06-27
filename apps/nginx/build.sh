#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly FILENAME="nginx-1.19.10.tar.gz"
readonly URL="https://nginx.org/download/$FILENAME"
readonly SHA256="e8d0290ff561986ad7cd6c33307e12e11b137186c4403a6a5ccdb4914c082d88"

curl -s -L "$URL" | tee "$FILENAME" | sha256sum -c <(echo "$SHA256  -")
mkdir nginx
tar -C nginx -xvf "$FILENAME" --strip 1
cd nginx

patch -Np1 -i ../nginx.patch

declare -xr PATH="$DIR/../../scripts:$PATH"
declare -xr CC=autoseccomp-clang
./configure --without-http_rewrite_module --without-pcre --without-http_gzip_module
make -j "$(nproc)"
