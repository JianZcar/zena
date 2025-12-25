#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"

# Download the kernel RPMs (and dependencies) into /tmp
dnf5 download --resolve --destdir "$TMPDIR" \
  kernel-cachyos \
  kernel-cachyos-devel-matched \
  kernel-cachyos-nvidia-open

# Install the RPM files without running scriptlets
rpm -U --noscripts --notriggers *.rpm

popd
rm -rf "$TMPDIR"

dnf5 versionlock add kernel-cachyos \
  kernel-cachyos-devel-matched \
  kernel-cachyos-nvidia-open

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
dnf5 -y install scx-scheds
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

echo "::endgroup::"
