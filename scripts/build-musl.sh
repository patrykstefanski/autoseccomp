#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly LLVM_BUILD_DIR="$DIR/../llvm-build"
readonly MUSL_BUILD_DIR="$DIR/../musl-build"

if [[ -v AUTOSECCOMP_ENABLE && "$AUTOSECCOMP_ENABLE" -eq "0" ]]; then
  enable_flag=""
else
  enable_flag="-fautoseccomp"
fi

declare -xr PATH="$LLVM_BUILD_DIR/bin:$PATH"
declare -xr CC=clang
declare -xr CFLAGS="-flto $enable_flag"
mkdir -p "$MUSL_BUILD_DIR/build"
cd "$MUSL_BUILD_DIR/build"
"$DIR/../musl/configure" --disable-shared --prefix="$MUSL_BUILD_DIR"
make -j "$(nproc)"
make install
