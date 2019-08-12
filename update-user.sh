#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

USAGE="usage: update_user.sh {old user name} {new user name} [new password]"

USERNAME_OLD="${1:-}"
USERNAME_NEW="${2:-}"
PASSWORD_NEW="${3:-}"

if [[ "$#" -lt 2 ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if who -u | grep -q "^$USERNAME_OLD "; then
	echo "${USERNAME_OLD} is currently logged in, users must be logged out to change their name"
	exit 1
fi

# Check if user USERNAME_OLD exists
id -u "$USERNAME_OLD"
# Check if group USERNAME_OLD exists
getent group "$USERNAME_OLD"

# Make sure user USERNAME_NEW doesn't already exist
if id -u "$USERNAME_NEW"; then
	echo "User ${USERNAME_NEW} already exists"
	exit 1
fi
# Make sure group USERNAME_NEW doesn't already exist
if getent group "$USERNAME_NEW"; then
	echo "Group ${USERNAME_NEW} already exists"
	exit 1
fi

# Change the username USERNAME_OLD to USERNAME_NEW
usermod -l "$USERNAME_NEW" "$USERNAME_OLD"
# If the old user had a conventional home directory...
if [ -d "/home/${USERNAME_OLD}" ]; then
	# ... rename it and update the users home folder
	mv "/home/${USERNAME_OLD}" "/home/${USERNAME_NEW}"
	usermod -m -d "/home/${USERNAME_NEW}" "$USERNAME_NEW"
fi
# Change the user group name
groupmod --new-name "$USERNAME_NEW" "$USERNAME_OLD"
# If a password has been supplied then change it
if [ "$PASSWORD_NEW" != "" ]; then
	echo "$USERNAME_NEW:$PASSWORD_NEW" | chpasswd
fi

# Add new username to pi-nopasswd so no password is required for sudo
sed -i "s/${USERNAME_OLD}/${USERNAME_NEW}/g" /etc/sudoers.d/010_pi-nopasswd

# Move crontabs file
if [ -f /var/spool/cron/crontabs/"${USERNAME_OLD}" ]; then
	mv -v /var/spool/cron/crontabs/"${USERNAME_OLD}" /var/spool/cron/crontabs/"${USERNAME_NEW}"
fi

# Move mail file
if [ -f /var/spool/mail/"${USERNAME_OLD}" ]; then
	mv -v /var/spool/mail/"${USERNAME_OLD}" /var/spool/mail/"${USERNAME_NEW}"
fi
