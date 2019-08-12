#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# This script performs some basic testing on the scripts in this repository
# It is designed to be run in a Raspbian environment

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
# Check the user name, password and group was changed
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
# The user should have a home, check is has also been changed
if [ ! -d "/home/${USER_NAME}" ]; then
	echo "Update user script failed to change the home directory"
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
# Check the hostname was changed
CURRENT_HOSTNAME=$(cat /etc/hostname)
echo "CURRENT_HOSTNAME: $CURRENT_HOSTNAME"
if [ "$NEW_HOSTNAME" != "$CURRENT_HOSTNAME" ]; then
	echo "Set hostname failed!"
	exit 1
fi

# Test install-wireguard.sh
echo "Will now test set Wireguard install script"
./install-wireguard.sh
# Check wg command is present
wg
if [ "$?" != 0 ]; then
	echo "Wireguard install failed!"
	exit 1
fi

# Test raspbian-setup.sh
echo "Will now test Raspbian setup script"
# Create config file
CONFIG_PATH=raspbian-setup.test.conf
echo "Will now build test config"
echo "CONFIG_PATH: $CONFIG_PATH"
echo "SILENT_BOOT=enable" >> $CONFIG_PATH
OLD_USER_NAME=$USER_NAME
USER_NAME="test-again"
USER_PASSWORD="password-again"
echo "UPDATE_USER=$OLD_USER_NAME,$USER_NAME,$USER_PASSWORD" >> $CONFIG_PATH
NEW_HOSTNAME="raspbian-setup-again"
echo "HOSTNAME=$NEW_HOSTNAME" >> $CONFIG_PATH
echo "INSTALL_WIREGUARD=true" >> $CONFIG_PATH
cat $CONFIG_PATH
# Run raspbian-setup.sh with created config file
./raspbian-setup.sh $CONFIG_PATH
# Check the user name, password and group was changed
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
# The user should have a home, check is has also been changed
if [ ! -d "/home/${USER_NAME}" ]; then
	echo "Update user script failed to change the home directory"
	exit 1
fi
# Check the hostname was changed
CURRENT_HOSTNAME=$(cat /etc/hostname)
echo "CURRENT_HOSTNAME: $CURRENT_HOSTNAME"
if [ "$NEW_HOSTNAME" != "$CURRENT_HOSTNAME" ]; then
	echo "Set hostname failed!"
	exit 1
fi
