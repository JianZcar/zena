#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

pushd /usr/lib/kernel/install.d
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

packages=(
  kernel-cachyos-lto
  kernel-cachyos-lto-devel-matched
)

for pkg in kernel kernel-core kernel-modules kernel-modules-core; do
  rpm --erase $pkg --nodeps
done

dnf5 -y install "${packages[@]}"
dnf5 versionlock add "${packages[@]}"

# Fix for Cachy Kernel not installing properly
rm -rf "/usr/lib/modules/$(ls /usr/lib/modules | head -n1)"

KFILE=$(ls /boot/vmlinuz-* | head -n1)
KVER="${KFILE#/boot/vmlinuz-}"

mv "/boot/vmlinuz-${KVER}" "/usr/lib/modules/${KVER}/vmlinuz"
mv "/boot/System.map-${KVER}" "/usr/lib/modules/${KVER}/System.map"
mv "/boot/config-${KVER}" "/usr/lib/modules/${KVER}/config"
mv "/boot/symvers-${KVER}.zst" "/usr/lib/modules/${KVER}/symvers.zst"
rm -rf /boot/*

dnf5 -y distro-sync

echo "::endgroup::"
