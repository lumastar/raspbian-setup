#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

SCRIPTS=("set-hostname.sh" "silent-boot.sh" "update-user.sh" "raspbian-setup.sh" "install-wireguard.sh")
ASSETS=("raspbian-setup.example.conf")

echo "BUILD - Will now pull Docker image"
docker pull quay.io/lumastar/raspbian-customiser:v0.2.2
echo "BUILD - Will now set scripts to be executable"
chmod +x ${SCRIPTS[@]}
echo "BUILD - Will now fetch dependencies"
sudo apt-get update
sudo apt-get install --yes shellcheck

echo "TEST - Will now test scripts"
for SCRIPT in "${SCRIPTS[@]}"; do
    shellcheck "$SCRIPT"
done
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
  quay.io/lumastar/raspbian-customiser:v0.2.2

echo "DEPOLY - Will now package scripts"
mkdir raspbian-setup
mv ${SCRIPTS[@]} raspbian-setup/
mv ${ASSETS[@]} raspbian-setup/
zip -r raspbian-setup-${TRAVIS_TAG}.zip raspbian-setup/
