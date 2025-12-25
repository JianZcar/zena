#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs

packages=(
  kernel-cachyos
  kernel-cachyos-devel-matched
  kernel-cachyos-nvidia-open
)

rpm -U --noscripts --notriggers ${packages[@]}

dnf5 versionlock add $packages

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y install scx-scheds
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

echo "::endgroup::"
