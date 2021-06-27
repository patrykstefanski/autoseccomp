#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly LLVM_BUILD_DIR="$DIR/../llvm-build"
readonly RUNTIME_BUILD_DIR="$DIR/../runtime-build"

declare -xr PATH="$LLVM_BUILD_DIR/bin:$PATH"

mkdir -p "$RUNTIME_BUILD_DIR"
clang -std=c99 -Wall -Wextra -Wconversion -c -Os -fPIC "$DIR/../runtime/autoseccomp.c" -o "$RUNTIME_BUILD_DIR/autoseccomp.o"
