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
    # Bazzite & Ublue
    ublue-os/packages
    ublue-os/staging

    atim/heroic-games-launcher
)

dnf5 -y copr disable "${COPRS_TO_DISABLE[@]}"

dnf5 config-manager setopt "*tailscale*".enabled=false
dnf5 config-manager setopt "terra-mesa".enabled=false
eval "$(/ctx/helper/dnf5-setopt.sh setopt '*negativo17*' enabled=false)"

echo "::endgroup::"
