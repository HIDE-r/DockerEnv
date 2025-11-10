#!/usr/bin/env bash

source param.env

start() {
    docker compose up -d
    ip addr add 192.168.77.1/24 dev ${IFACE}
}

stop() {
    docker compose down
    ip addr del 192.168.77.1/24 dev ${IFACE}
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
