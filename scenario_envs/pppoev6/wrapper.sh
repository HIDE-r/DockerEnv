#!/usr/bin/env bash

verbose=0
detach=0

prt() {
    if [ "$verbose" = "1" ]; then echo "$(basename "$0"): $*"; fi
}

run() {
	if [ "${verbose}" = "1" ]; then
		echo ""
		echo "===> [RUN] $*"
		echo ""
	fi

	eval "$*" || exit $?
}

usage() {
    echo "usage: $(basename "$0") [-ilpdsv]"
    echo "  options:"
    printf "  %-20s %s\n" "-i, --iface"         "The bind interface"
    printf "  %-20s %s\n" "-l, --local_ip"      "Local PPPoE interface IP"
    printf "  %-20s %s\n" "-p, --pool_start_ip" "Start address of remote IP pool"
    printf "  %-20s %s\n" "-d, --detach" 	"run docker compose in detach mode"
    printf "  %-20s %s\n" "-s, --super_user" 	"run docker compose in privilege"
    printf "  %-20s %s\n" "-v, --verbose" 	"verbose message"
    echo ""
    echo "example:"
    echo "  ./wrapper.sh -s -i enp1s0 -l 10.1.1.1 -p 10.1.1.2"
}

docker_compose_up() {
	local privilege="$1"
	local detach="$2"

	if [ "${privilege}" == "1" ]; then
		preface="sudo "
	fi

	# 当 docker compose 使用 sudo 调用 root 用户执行时, 当前的环境变量不起作用, 故这里使用变量替换的方式解决
	preface+="IFACE=${IFACE} "
	preface+="LOCAL_IP=${LOCAL_IP} "
	preface+="POOL_START_IP=${POOL_START_IP} "

	if [ "$detach" == "1" ]; then
		run ${preface} docker compose up -d
	else 
		run ${preface} docker compose up
	fi
}

main() {
	if [ $# -eq 0 ]; then
		usage
		exit 0
	fi

	if ! OPTS=$(getopt -o 'hi:l:p:dsv' --long help,iface:local_ip:pool_start_ip:detach,super_user,verbose -n 'parse-options' -- "$@"); then
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
			-s | --super_user)	privilege=1; shift;;
			-v | --verbose)		verbose=1; shift;;
			-- ) shift; break ;;
			* ) err "unsupported argument $1"; usage; exit 1 ;;
		esac
	done

	prt "interface=${IFACE}"
	prt "local_ip=${LOCAL_IP}"
	prt "pool_start_ip=${POOL_START_IP}"
	prt "detach=${detach}"
	prt "privilege=${privilege}"

	echo -e "======================================================================\n"

	docker_compose_up "${privilege}" "${detach}"
}

rm -rf ./env_data/*
main "$@"
