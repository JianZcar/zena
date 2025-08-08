#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

# Create directory
mkdir -p /var/roothome

dnf5 -y install dnf5-plugins

# Enable COPR repositories
COPRS=(
    bazzite-org/bazzite
    ublue-os/packages
    ublue-os/staging
    ublue-os/akmods

    #WM
    yalter/niri

    # Fonts
    che/nerd-fonts

    # Gaming
    hikariknight/looking-glass-kvmfr
    atim/heroic-games-launcher
)

for COPR in "${COPRS[@]}"; do
    echo "Enabling copr: $COPR"
    dnf5 -y copr enable "$COPR"
done
unset COPR

# Install RPMFusion repos
dnf5 -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Add Terra repo
#
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "terra-nvidia".enabled=false

# Add Tailscale repo
dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
