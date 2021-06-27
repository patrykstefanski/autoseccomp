#!/bin/bash

set -Eeuo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

"$DIR/build-libevent.sh"
"$DIR/build-memcached.sh"
