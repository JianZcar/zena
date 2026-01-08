#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  kernel-cachyos-lto
  kernel-cachyos-lto-devel-matched
)

dnf5 -y remove --no-autoremove \
  kernel kernel-core \
  kernel-modules kernel-modules-core \
  kernel-modules-extra kernel-tools \
  kernel-tools-libs

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"

dnf5 download --arch x86_64 --resolve --destdir "$TMPDIR" "${packages[@]}"
rpm -U --noscripts --notriggers *.rpm

popd
rm -rf "$TMPDIR"

rpm --rebuilddb
dnf5 clean all
dnf5 makecache
dnf5 check
dnf5 -y distro-sync

dnf5 versionlock add "${packages[@]}"

echo "::endgroup::"
