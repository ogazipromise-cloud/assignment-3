#!/usr/bin/env bash

set -u

show_help() {
echo "DevOps Tool"
echo
echo "Usage: $0 <command> [arguments]"
echo
echo "Commands:"
echo "  system-info                 Display system information"
echo "  check-host <host>           Resolve and check a host"
echo "  check-port <host> <port>    Check TCP connectivity"
echo "  help                        Display this help message"
}

system_info() {
echo "===== System Information ====="
echo "Hostname: $(hostname)"
echo "Current User: $(whoami)"
echo "Date/Time: $(date)"
echo "Operating System: $(uname -s)"
echo "Kernel Version: $(uname -r)"
echo "Uptime: $(uptime -p)"
}

check_host() {
local host="$1"
local resolved_address


resolved_address=$(getent hosts "$host" | awk 'NR==1 {print $1}')

if [[ -z "$resolved_address" ]]; then
    echo "Error: Unable to resolve host: $host" >&2
    return 1
fi

echo "Host: $host"
echo "Resolved Address: $resolved_address"

if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
    echo "Connectivity: Successful"
    return 0
else
    echo "Connectivity: Failed"
    return 1
fi


}

check_port() {
local host="$1"
local port="$2"


if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be numeric." >&2
    return 2
fi

if (( port < 1 || port > 65535 )); then
    echo "Error: Port must be between 1 and 65535." >&2
    return 2
fi

echo "Checking $host on TCP port $port..."

if timeout 5 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
    echo "TCP connectivity: Successful"
    return 0
else
    echo "TCP connectivity: Failed"
    return 1
fi


}

main() {
local command="${1:-}"


case "$command" in
    system-info)
        if [[ $# -ne 1 ]]; then
            echo "Error: system-info does not accept arguments." >&2
            exit 2
        fi
        system_info
        ;;

    check-host)
        if [[ $# -ne 2 || -z "${2:-}" ]]; then
            echo "Error: check-host requires a host." >&2
            exit 2
        fi
        check_host "$2"
        ;;

    check-port)
        if [[ $# -ne 3 || -z "${2:-}" || -z "${3:-}" ]]; then
            echo "Error: check-port requires a host and port." >&2
            exit 2
        fi
        check_port "$2" "$3"
        ;;

    help|--help|-h)
        show_help
        ;;

    "")
        echo "Error: Missing command." >&2
        show_help
        exit 2
        ;;

    *)
        echo "Error: Invalid command: $command" >&2
        show_help
        exit 2
        ;;
esac


}

main "$@"
