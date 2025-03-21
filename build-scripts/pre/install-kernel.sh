#!/bin/bash

set -oue pipefail

INSTALLED_KERNEL_PACKAGES="$(rpm -qa --qf "%{NAME}\n" | grep -P '^kernel(?!-tools).*')"

YUM_DIR="/etc/yum.repos.d/"
REPO="bieszczaders/kernel-cachyos/repo/fedora-$(rpm -E %fedora)/bieszczaders-kernel-cachyos-fedora-$(rpm -E %fedora).repo"
wget -P $YUM_DIR "https://copr.fedorainfracloud.org/coprs/$REPO"

printf "### Packages to be replaced ###\n$INSTALLED_KERNEL_PACKAGES\n\n"
sleep 2

rpm-ostree cliwrap install-to-root / && \
rpm-ostree override remove $INSTALLED_KERNEL_PACKAGES --install=kernel-cachyos-lts
rm "$YUM_DIR$REPO"
