#!/usr/bin/env bash

export IFACE="$1"

./wrapper.sh -i ${IFACE} -l 10.1.1.1 -p 10.1.1.2 -d
