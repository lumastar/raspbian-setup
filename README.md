# raspbian-setup

[![Build Status](https://travis-ci.com/lumastar/raspbian-setup.svg?branch=master)](https://travis-ci.com/lumastar/raspbian-setup)

Scripts to make setup of Raspbian quicker and easier.

Travis CI is used to test the scripts as much as is possible and package them into an archive which can be dowloaded and installed in Raspbian.

Note the automatic testing of some scripts is limited, while it shows they will run correctly it does not guarantee they will perform the desired result. For this reason manual testing should be carried out on a Raspberry Pi before tagging new versions.

## main script

The main script `rasbian-setup.sh` takes two arguments, a config file location and a log file location. The config file can specify values for each of the sub scripts, which set up Raspbian as described below. The log file is where the output of these scripts is saved to.

This can be used when configuring Raspbian as part of a CI/CD pipeline. It can also be set up to run when Raspbian boots, reading the config frile from the `/boot` partition, which can be edited on another (non linux) computer after writing an SD card.

An example config file is included in the repo.

## sub scripts

Currently the following scripts are available:

*  `set-hostname.sh` - set the system hostname
*  `silent-boot.sh` - make the boot process silent so no messages are output to the connected display
*  `update-user.sh` - change the user name, group and password
