#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra

KERNEL_PKGS=(
    /tmp/kernel-rpms/kernel-[0-9]*.rpm
    /tmp/kernel-rpms/kernel-core-*.rpm
    /tmp/kernel-rpms/kernel-modules-*.rpm
    /tmp/kernel-rpms/kernel-modules-core-*.rpm
    /tmp/kernel-rpms/kernel-modules-extra-*.rpm
    /tmp/kernel-rpms/kernel-devel-*.rpm
)

dnf5 -y install "${KERNEL_PKGS[@]}"

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-uki-virt

dnf5 -y install /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm

dnf5 -y config-manager setopt "*rpmfusion*".enabled=false 
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons 
dnf5 -y install scx-scheds
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

echo "::endgroup::"
