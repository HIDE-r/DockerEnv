#!/usr/bin/env bash

export IFACE="$1"
export CTR_UID="$(id -u)"
export CTR_GID="$(id -g)"

if [ -e data ]; then
	rm -rf data
fi

mkdir data

docker compose up
