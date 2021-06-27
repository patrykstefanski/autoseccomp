#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

readonly LLVM_BUILD_DIR="$DIR/../llvm-build"

mkdir -p "$LLVM_BUILD_DIR"
cd "$LLVM_BUILD_DIR"
declare -xr CC=clang
declare -xr CXX=clang++
cmake \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=On \
  -DLLVM_ENABLE_LLD=On \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_INCLUDE_BENCHMARKS=Off \
  -DLLVM_PARALLEL_LINK_JOBS=2 \
  "$DIR/../llvm-project/llvm"
ninja
