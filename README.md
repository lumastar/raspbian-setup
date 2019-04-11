# raspbian-setup

[![Build Status](https://travis-ci.com/lumastar/raspbian-setup.svg?branch=master)](https://travis-ci.com/lumastar/raspbian-setup)

Scripts to make setup of Raspbian quicker and easier.

Travis CI is used to test the scripts as much as is possible and package them into an archive which can be dowloaded and installed in Raspbian.

Note the automatic testing of some scripts is limited, while it shows they will run correctly it does not guarantee they will perform the desired result. For this reason manual testing should be carried out on a Raspberry Pi before tagging new versions.

## service

The plan for the project is to create a system service that reads a config file and sets up Raspbian based on the values it specifies. By storing the config file in the `/boot` partition it can be written after writing an SD card, before Raspbian is booted. This makes it quicker and easier to get set up, especially when setting up multiple SD cards.

This service will use a combination of the scripts in this repository and the `raspi-config` program.

## scripts

Currently the following scripts are available:

*  `set-hostname.sh` - set the system hostname
*  `silent-boot.sh` - make the boot process silent so no messages are output to the connected display
*  `update-user.sh` - change the user name, group and password
