#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

USAGE="usage: update_user.sh {old user name} {new user name} {new password}"

# TODO: if no new password is given then do not change the password

if [[ "$#" -ne 3 ]]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root"
   exit 1
fi

# TODO: check if USERNAME_OLD is logged in

USERNAME_OLD=$1
USERNAME_NEW=$2
PASSWORD_NEW=$3

# Check if user USERNAME_OLD exists
id -u $USERNAME_OLD
if [[ $? == 0 ]]; then
	# Change the username USERNAME_OLD to the new username
	usermod -l $USERNAME_NEW $USERNAME_OLD
	if [ $? != "0" ]; then
		echo "Error changing username, exiting..."
		exit 1
	fi
else
	# If the user USERNAME_OLD doesn't exist check if the new username exists
	id -u $USERNAME_NEW
	if [ $? != "0" ]; then
		echo "Error changing username, no users named $USERNAME_OLD or $USERNAME_NEW exist, exiting..."
		exit 1
	else
		echo "Warning, no user called $USERNAME_OLD and user called $USERNAME_NEW exists, assuming name has already been changed and proceeding"
	fi
fi

usermod -m -d /home/$USERNAME_NEW $USERNAME_NEW
if [ $? != "0" ]; then
	echo "Error changing user home folder, exiting..."
	exit 1
fi

# Check if group USERNAME_OLD exists
getent group $USERNAME_OLD
if [ $? == "0" ]; then
	# Change the username USERNAME_OLD to the new username
	groupmod --new-name $USERNAME_NEW $USERNAME_OLD
	if [ $? != "0" ]; then
		echo "Error changing group name, exiting..."
		exit 1
	fi
else
	# If the user USERNAME_OLD doesn't exist check if the new username exists
	getent group $USERNAME_NEW
	if [ $? != "0" ]; then
		echo "Error changing group name, no groups named $USERNAME_OLD or $USERNAME_NEW exist, exiting..."
		exit 1
	else
		echo "Warning, no group called $USERNAME_OLD, group called $USERNAME_NEW exists, assuming name has already been changed and proceeding"
	fi
fi

# Add new username to pi-nopasswd so no password is required for sudo
sed -i "s/${USERNAME_OLD}/${USERNAME_NEW}/g" /etc/sudoers.d/010_pi-nopasswd
if [ $? != "0" ]; then
	echo "Could not add new user to 010_pi-nopasswd, will ignore..."
fi

# Move crontabs file
if [ -f /var/spool/cron/crontabs/"${USERNAME_OLD}" ]; then
	mv -v /var/spool/cron/crontabs/"${USERNAME_OLD}" /var/spool/cron/crontabs/"${USERNAME_NEW}"
fi

# Move mail file
if [ -f /var/spool/mail/"${USERNAME_OLD}" ]; then
	mv -v /var/spool/mail/"${USERNAME_OLD}" /var/spool/mail/"${USERNAME_NEW}"
fi

# Set password
echo "$USERNAME_NEW:$PASSWORD_NEW" | chpasswd
if [ $? != "0" ]; then
	echo "Error changing user password, exiting..."
	exit 1
fi

exit 0
