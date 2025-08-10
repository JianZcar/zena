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
)
for repo in "${DISABLE_REPOS[@]}"; do
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/"$repo".repo
done

COPRS_TO_DISABLE=(
    # Bazzite & Ublue
    bazzite-org/bazzite
    bazzite-org/bazzite-multilib
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    ublue-os/packages
    ublue-os/staging
    ublue-os/akmods 

    # Fonts
    che/nerd-fonts

    # Gaming
    hikariknight/looking-glass-kvmfr

    # Multimedia
    ycollet/audinux

    # Gaming
    atim/heroic-games-launcher
)
for copr in "${COPRS_TO_DISABLE[@]}"; do
    dnf5 -y copr disable "$copr"
done

dnf5 config-manager setopt "*tailscale*".enabled=0
dnf5 config-manager setopt "terra-mesa".enabled=0
eval "$(/ctx/dnf5-setopt.sh setopt '*negativo17*' enabled=0)"

echo "::endgroup::"
