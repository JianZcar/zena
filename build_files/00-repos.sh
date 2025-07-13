#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

# Create directory
mkdir -p /var/roothome

# Install dnf5 plugins
dnf5 -y install dnf5-plugins

# Enable COPR repositories
COPRS=(
    # Bazzite & Ublue
    bazzite-org/bazzite
    bazzite-org/bazzite-multilib
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    ublue-os/packages
    ublue-os/staging

    # Fonts
    che/nerd-fonts

    # Gaming
    hikariknight/looking-glass-kvmfr

    # Hardware
    hhd-dev/hhd

    # Multimedia
    ycollet/audinux

    # Gaming
    atim/heroic-games-launcher
)

for COPR in "${COPRS[@]}"; do
    echo "Enabling copr: $COPR"
    dnf5 -y copr enable "$COPR"
    dnf5 -y config-manager setopt "copr:copr.fedorainfracloud.org:${COPR////:}.priority=98"
done
unset COPR

# Add Terra repo (custom repopath)
dnf5 -y install --nogpgcheck \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    terra-release terra-release-extras

# Add Tailscale repo
dnf5 -y config-manager addrepo --overwrite \
    --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

# Install RPMFusion repos
dnf5 -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Enable Negativo17 multimedia repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# add additional negativo17 repos
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-rar.repo

# set priorities and exclusions
dnf5 -y config-manager setopt "*bazzite*".priority=1
dnf5 -y config-manager setopt "*akmods*".priority=2
dnf5 -y config-manager setopt "terra-mesa".enabled=true
dnf5 -y config-manager setopt "terra-nvidia".enabled=false

# negativo17
eval "$(/ctx/dnf5-setopt.sh setopt '*negativo17*' priority=4 exclude='mesa-* *xone*')"

dnf5 -y config-manager setopt "*".exclude="*.aarch64"
dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"
dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*"

# Remove fedora default repo
flatpak remote-modify --disable fedora
curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | sudo tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

echo "::endgroup::"
