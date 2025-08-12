#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

sed -i "s/^VERSION=.*/VERSION=\"${RELEASE} (Zena)\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME}/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Zena ${RELEASE}.${VERSION_DATE} (Fedora)\"/" /usr/lib/os-release
echo "OSTREE_VERSION=\"${VERSION_TAG}\"" >> /usr/lib/os-release

sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
echo "::endgroup::"
