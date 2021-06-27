#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly FILENAME="coreutils-8.32.tar.xz"
readonly URL="https://ftp.gnu.org/gnu/coreutils/$FILENAME"
readonly SHA256="4458d8de7849df44ccab15e16b1548b285224dbba5f08fac070c1c0e0bcc4cfa"

curl -s -L "$URL" | tee "$FILENAME" | sha256sum -c <(echo "$SHA256  -")
mkdir coreutils
tar -C coreutils -xvf "$FILENAME" --strip 1
cd coreutils
patch -Np1 -i ../coreutils.patch

declare -xr PATH="$DIR/../../scripts:$PATH"
declare -xr CC=autoseccomp-clang
declare -xr AUTOSECCOMP_PIE=0
./configure
make -j "$(nproc)"
