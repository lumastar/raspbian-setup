#!/bin/bash

# Based on the guide here https://github.com/adrianmihalko/raspberrypiwireguard

# TODO: Make this work in containerised / virtualised CI pipeline so it's ready to go as soon as images arer written to SD cards

set -e

if [[ $EUID -ne 0 ]]; then
   echo "this script requires root privileges" 
   exit 1
fi

apt-get update
apt-get upgrade -y
apt-get install -y raspberrypi-kernel-headers
echo "deb http://deb.debian.org/debian/ unstable main" | sudo tee --append /etc/apt/sources.list.d/unstable.list
apt-get install -y dirmngr 
apt-key adv --keyserver   keyserver.ubuntu.com --recv-keys 8B48AD6246925553 
printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' | sudo tee --append /etc/apt/preferences.d/limit-unstable
apt-get update
apt-get install -y --allow-unauthenticated wireguard 
perl -pi -e 's/#{1,}?net.ipv4.ip_forward ?= ?(0|1)/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf 
echo "please reboot now to complete installation"
