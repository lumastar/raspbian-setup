#!/bin/bash

set -e

# Test silent_boot.sh
./silent_boot.sh enable
./silent_boot.sh disable

# Test update_user.sh
./update_user.sh pi test test
ls /home

# Test set_hostname.sh
./set_hostname.sh hostname
cat /etc/hostname
