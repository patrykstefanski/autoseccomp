#!/bin/bash

set -Eeuo pipefail

cd memcached
./testapp
prove ./t
