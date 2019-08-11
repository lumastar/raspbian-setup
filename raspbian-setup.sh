#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

USAGE="usage: raspbian-setup.sh {config-path}"

if [[ "$#" -ne 1 ]]; then
    echo "$USAGE"
    exit 1
fi
CONFIG_PATH=${1:-}

if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root"
   exit 1
fi

while read line; do
	IFS="=" read -a lineparts <<<"$line"
	case "${lineparts[0]}" in
		SILENT_BOOT)
			./silent-boot.sh "${lineparts[1]}"
			;;
		HOSTNAME)
			./set-hostname.sh "${lineparts[1]}"
			;;
		UPDATE_USER)
			IFS="," read -a argparts <<<"${lineparts[1]}"
			./update-user.sh "${argparts[0]}" "${argparts[1]}" "${argparts[2]}"
			;;
		INSTALL_WIREGUARD)
			if [ "${lineparts[1]}" == "true" ]; then
				./install-wireguard.sh
			fi
			;;
	esac
done < "$CONFIG_PATH"