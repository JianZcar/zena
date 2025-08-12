#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
DATE=$(date +%Y%m%d)

sed -i "s/^VERSION=.*/VERSION=\"${RELEASE} (Zena)\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=zena/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Zena ${RELEASE}.${DATE} (Fedora)\"/" /usr/lib/os-release
echo "OSTREE_VERSION=\"${DEFAULT_TAG}.${DATE}\"" >> /usr/lib/os-release

sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
echo "::endgroup::"
