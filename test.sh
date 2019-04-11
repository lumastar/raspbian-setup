#!/bin/bash

# This script performs some basic testing on the scripts in this repository
# It is designed to be run in a Raspbian environment

set -e

echo "Will now test raspbian-setup scripts"
cd /raspbian-setup

# Test silent-boot.sh
echo "Will now test silent boot script"
./silent-boot.sh enable
./silent-boot.sh disable

# Test update-user.sh
echo "Will now test update user script"
USER_NAME=test-name
USER_PASSWORD=test-password
echo "Will change pi user name and group to $USER_NAME and password to $USER_PASSWORD"
./update-user.sh pi $USER_NAME $USER_PASSWORD
# Try running whoami as the changed user
su $USER_NAME <<EOSU
$USER_PASSWORD
whoami
EOSU
# Check the users group has been changed
if ! $(id -Gn $USER_NAME | grep -qw $USER_NAME); then
	echo "Update user script failed to change group"
	exit 1
fi

# Test set-hostname.sh
echo "Will now test set hostname script"
CURRENT_HOSTNAME=$(cat /etc/hostname)
echo "CURRENT_HOSTNAME: $CURRENT_HOSTNAME"
NEW_HOSTNAME=raspbian-setup-test
echo "NEW_HOSTNAME: $NEW_HOSTNAME"
echo "Setting hostname to NEW_HOSTNAME..."
./set-hostname.sh $NEW_HOSTNAME
CURRENT_HOSTNAME=$(cat /etc/hostname)
echo "CURRENT_HOSTNAME: $CURRENT_HOSTNAME"
if [ "$NEW_HOSTNAME" != "$CURRENT_HOSTNAME" ]; then
	echo "Set hostname failed!"
	exit 1
fi
