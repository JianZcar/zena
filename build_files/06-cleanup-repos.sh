#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

DISABLE_REPOS=(
    fedora-cisco-openh264
    fedora-steam
    fedora-rar
    terra
    terra-extras
    negativo17-fedora-multimedia
    _copr_ublue-os-akmods
)
for repo in "${DISABLE_REPOS[@]}"; do
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/"$repo".repo
done

COPRS_TO_DISABLE=(
    bazzite-org/bazzite
    bazzite-org/bazzite-multilib
    ublue-os/staging
    ublue-os/packages
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    ycollet/audinux
    bazzite-org/rom-properties
    bazzite-org/webapp-manager
    hhd-dev/hhd
    che/nerd-fonts
    mavit/discover-overlay
    lizardbyte/beta
    rok/cdemu
    hikariknight/looking-glass-kvmfr
)
for copr in "${COPRS_TO_DISABLE[@]}"; do
    dnf5 -y copr disable "$copr"
done

echo "::endgroup::"
