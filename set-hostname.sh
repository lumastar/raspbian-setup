#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

USAGE="usage: set-hostname.sh {hostname}"

if [ "$#" -ne 1 ]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "this script requires root privileges"
   exit 1
fi

NEW_HOSTNAME=$1
OLD_HOSTNAME=$(cat /etc/hostname)

if [ "$OLD_HOSTNAME" != "$(hostname)" ]; then
	echo "current hostname is not the same as hostname specified in /etc/hostname"
	echo "both will be update to the specified hostname"
fi

# Change the host name in config files
sed -i -e "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sed -i -e "s/$OLD_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

# Change current hostname
hostname "$NEW_HOSTNAME"

exit 0