#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

DISABLE_REPOS=(
    fedora-cisco-openh264
    fedora-nvidia
    fedora-multimedia
    fedora-steam
    fedora-rar
    terra
    terra-extras
)
for repo in "${DISABLE_REPOS[@]}"; do
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/"$repo".repo
done

COPRS_TO_DISABLE=(
    bazzite-org/bazzite
    bazzite-org/bazzite-multilib
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    ublue-os/packages
    ublue-os/staging

    atim/heroic-games-launcher
)

for copr in "${COPRS_TO_DISABLE[@]}"; do
    dnf5 -y copr disable "$copr"
done

dnf5 config-manager setopt "*tailscale*".enabled=false
dnf5 config-manager setopt "terra-mesa".enabled=false
eval "$(/ctx/helper/dnf5-setopt.sh setopt '*negativo17*' enabled=false)"

echo "::endgroup::"
