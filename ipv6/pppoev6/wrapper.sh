#!/usr/bin/env bash

detach=0

prt() {
    echo "$(basename "$0"): $*"
}

usage() {
    echo "usage: $(basename "$0") [-ilpd]"
    echo "  options:"
    printf "  %-20s %s\n" "-i, --iface"         "The bind interface"
    printf "  %-20s %s\n" "-l, --local_ip"      "Local PPPoE interface IP"
    printf "  %-20s %s\n" "-p, --pool_start_ip" "Start address of remote IP pool"
    printf "  %-20s %s\n" "-d, --detach" 	"run docker compose in detach mode"
}

docker_compose_up() {
	local detach="$1"

	if [ "$detach" == "1" ]; then
		docker compose up -d
	else 
		docker compose up
	fi
}

main() {
	if [ $# -eq 0 ]; then
		usage
		exit 0
	fi

	if ! OPTS=$(getopt -o 'hi:l:p:d' --long help,iface:local_ip:pool_start_ip:detach -n 'parse-options' -- "$@"); then
		err "Failed parsing options." >&2
		usage
		exit 1
	fi

	eval set -- "$OPTS"

	while true; do
		case "$1" in
			-h | --help)		usage; exit 0 ;;
			-i | --iface)		export IFACE="$2"; shift ; shift ;;
			-l | --local_ip)	export LOCAL_IP="$2"; shift ; shift ;;
			-p | --pool_start_ip)	export POOL_START_IP="$2"; shift ; shift ;;
			-d | --detach)		detach=1; shift;;
			-- ) shift; break ;;
			* ) err "unsupported argument $1"; usage; exit 1 ;;
		esac
	done

	prt "interface=${IFACE}"
	prt "local_ip=${LOCAL_IP}"
	prt "pool_start_ip=${POOL_START_IP}"
	prt "detach=${detach}"

	echo -e "======================================================================\n"

	docker_compose_up ${detach}
}

main "$@"
