#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

CONFIG_PATH=$1

# Create a log file
LOG_PATH=$2
echo "raspbian-setup.sh" > $LOG_PATH
date +"%Y-%m-%d-%T" > $LOG_PATH

while read line; do
	IFS="=" read -a lineparts <<<"$line"
	case "${lineparts[0]}" in
		SILENT_BOOT)
			./silent-boot.sh "${lineparts[1]}" > $LOG_PATH
			;;
		HOSTNAME)
			./set-hostname.sh "${lineparts[1]}" > $LOG_PATH
			;;
		UPDATE_USER)
			IFS="," read -a argparts <<<"${lineparts[1]}"
			./update-user.sh "${argparts[0]}" "${argparts[1]}" "${argparts[2]}" > $LOG_PATH
			;;
		INSTALL_WIREGUARD)
			if [ "${lineparts[1]}" == "true" ]; then
				./install-wireguard.sh
			fi
			;;
	esac
done < "$CONFIG_PATH"