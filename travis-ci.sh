#!/bin/bash

set -e

SCRIPTS=("set-hostname.sh" "silent-boot.sh" "update-user.sh")

echo "BUILD - Will now pull Docker image"
docker pull edwardotme/raspbian-customiser:v0.2
echo "BUILD - Will now set scripts to be executable"
chmod +x ${SCRIPTS[@]}

echo "TEST - Will now test scripts"
IMAGE_LINK=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-10-11/2018-10-09-raspbian-stretch-lite.zip
wget -nv $IMAGE_LINK
IMAGE_ZIP=$(basename $IMAGE_LINK)
unzip -o $IMAGE_ZIP
rm $IMAGE_ZIP
docker run --privileged --rm \
  -e MOUNT=/raspbian-setup \
  -e SOURCE_IMAGE=/raspbian-setup/${IMAGE_ZIP%.zip}.img \
  -e SCRIPT=/raspbian-setup/test.sh \
  -e ADD_DATA_PART=true \
  --mount type=bind,source="$(pwd)",destination=/raspbian-setup \
  edwardotme/raspbian-customiser:v0.2

echo "DEPOLY - Will now package scripts"
zip raspbian-setup-${TRAVIS_TAG}.zip ${SCRIPTS[@]}
