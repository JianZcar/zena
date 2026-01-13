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

dnf5 -y remove --no-autoremove \
  kernel kernel-core \
  kernel-modules kernel-modules-core \
  kernel-modules-extra kernel-tools \
  kernel-tools-libs

dnf5 -y install "${packages[@]}"
dnf5 versionlock add "${packages[@]}"

ls /boot

echo "::endgroup::"
