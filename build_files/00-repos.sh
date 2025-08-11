#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
mkdir -p /var/roothome

COPRS=(
    bazzite-org/bazzite
    bazzite-org/bazzite-multilib
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    ublue-os/packages
    ublue-os/staging 
    ublue-os/akmods 

    atim/heroic-games-launcher
)

for COPR in "${COPRS[@]}"; do
    echo "Enabling copr: $COPR"
    dnf5 -y copr enable "$COPR"
done

# Add Terra repo (custom repopath)
dnf5 -y install --nogpgcheck \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    terra-release terra-release-extras

# Install RPMFusion repos
dnf5 -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${RELEASE}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${RELEASE}.noarch.rpm"

REPOFILES=(
    https://negativo17.org/repos/fedora-nvidia.repo
    https://negativo17.org/repos/fedora-multimedia.repo
    https://negativo17.org/repos/fedora-steam.repo
    https://negativo17.org/repos/fedora-rar.repo

    https://pkgs.tailscale.com/stable/fedora/tailscale.repo
)

# Loop and add repos
for REPO in "${REPOFILES[@]}"; do
    dnf5 -y config-manager addrepo --from-repofile="$REPO"
done

# set priorities and exclusions
dnf5 -y config-manager setopt "*".exclude="*.aarch64"
dnf5 -y config-manager setopt "*fedora*".priority=1 "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"
dnf5 -y config-manager setopt "*akmods*".priority=2

eval "$(/ctx/helper/dnf5-setopt.sh setopt '*negativo17*' priority=3 exclude='mesa-* *xone*')"

dnf5 -y config-manager setopt "*rpmfusion*".priority=4 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "terra-mesa".priority=5 "terra-mesa".enabled=true 
dnf5 -y config-manager setopt "terra-nvidia".enabled=false
