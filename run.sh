#!/usr/bin/env bash

RPC=$1; shift
LANG=$1; shift
BIN=$1; shift

docker run -it --rm --net=host -p 50051:50051 -v `pwd`/data:/data ${RPC}-${LANG}-${BIN} "$@"
