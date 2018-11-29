# raspbian-setup

[![Build Status](https://travis-ci.com/EDWARDOtme/raspbian-setup.svg?branch=master)](https://travis-ci.com/EDWARDOtme/raspbian-setup)

Scripts to make setup of Raspbian quicker and easier.

## service

The plan for the project is to create a system service that reads a config file and sets up Raspbian based on the values it specifies. By storing the config file in the `/boot` partition it can be written after writing an SD card, before Raspbian is booted. This makes it quicker and easier to get set up, especially when setting up multiple SD cards.

This service will use a combination of the scripts in this repository and the `raspi-config` program.

## scripts

Currently the following scripts are available:

*  `set-hostname.sh` - set the system hostname
*  `silent_boot.sh` - make the boot process silent so no messages are output to the connected display
*  `update_user.sh` - change the user name, group and password
