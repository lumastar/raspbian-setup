#!/bin/bash

set -e

echo "Will now test raspbian-setup scripts"
cd /raspbian-setup

# Test silent_boot.sh
echo "Will now test silent boot script"
./silent_boot.sh enable
./silent_boot.sh disable

# Test update_user.sh
echo "Will now test update user script"
USER_NAME=test-name
USER_PASSWORD=test-password
echo "Will change pi user name and group to $USER_NAME and password to $USER_PASSWORD"
./update_user.sh pi $USER_NAME $USER_PASSWORD
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

# Test set_hostname.sh
echo "Will now test set hostname script"
CURRENT_HOSTNAME=$(cat /etc/hostname)
echo "CURRENT_HOSTNAME: $CURRENT_HOSTNAME"
NEW_HOSTNAME=raspbian-setup-test
echo "NEW HOSTNAME: $NEW_HOSTNAME"
./set_hostname.sh $NEW_HOSTNAME
CURRENT_HOSTNAME=$(cat /etc/hostname)
if [ $NEW_HOSTNAME != $CURRENT_HOSTNAME ]; then
	echo "Set hostname failed!"
	exit 1
]
