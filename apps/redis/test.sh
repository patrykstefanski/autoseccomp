#!/bin/bash

set -Eeuo pipefail

cd redis

# The musl library does not support backtrace, which is required for the
# integration/logging test. The runtest script normally detects this and skips
# the test. However, we linked the redis binaries statically and the script
# cannot do it. Thus, we skip the test right here.
# See: tests/integration/logging.tcl
./runtest --skipunit integration/logging
