#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

USAGE="usage: silent-boot.sh {enable|disable}"

if [ "$#" -ne 1 ]; then
    echo "$USAGE"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root"
   exit 1
fi

case "$1" in

	enable)

		sed -i -e "s/ console=tty1//g" /boot/cmdline.txt

		sed -i -e "s/ logo.nologo//g" /boot/cmdline.txt
		sed -i -e "1 s/$/ logo.nologo/g" /boot/cmdline.txt

		if ! grep -q "disable_splash=1" /boot/config.txt; then
			echo -ne "\n# Disable rainbow square splash screen\ndisable_splash=1\n" >> /boot/config.txt
		fi

		sed -i -e "s/#\s*disable_splash=1/disable_splash=1/g" /boot/config.txt

		systemctl disable getty@tty1.service

		;;

	disable)

		sed -i -e "s/ console=tty1//g" /boot/cmdline.txt
		sed -i -e "1 s/$/ console=tty1/g" /boot/cmdline.txt

		sed -i -e "s/ logo.nologo//g" /boot/cmdline.txt

		sed -i -e "s/#\s*disable_splash=1/disable_splash=1/g" /boot/config.txt
		sed -i -e "s/disable_splash=1/#disable_splash=1/g" /boot/config.txt

		systemctl enable getty@tty1.service

		;;

	*)

		echo "$USAGE"
		;;

esac

exit 0