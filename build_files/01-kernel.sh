#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 -y remove --no-autoremove \
  kernel \
  kernel-core \
  kernel-modules \
  kernel-modules-core \
  kernel-modules-extra \
  kernel-tools \
  kernel-tools-libs

TMPDIR=$(mktemp -d)
pushd "$TMPDIR"

dnf5 download --resolve --destdir "$TMPDIR" \
  kernel-cachyos \
  kernel-cachyos-devel-matched \
  kernel-cachyos-nvidia-open

rpm -U --noscripts --notriggers *.rpm

popd
rm -rf "$TMPDIR"

dnf5 versionlock add kernel-cachyos \
  kernel-cachyos-devel-matched \
  kernel-cachyos-nvidia-open

echo "::endgroup::"
