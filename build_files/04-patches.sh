#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Define repositories and the packages to be swapped from them
declare -A PKGS_TO_SWAP=(
    ["terra-extras"]="switcheroo-control gnome-shell"
    ["terra-mesa"]="mesa-filesystem"
    ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd"
)

# Swap packages from the specified repositories
for repo in "${!PKGS_TO_SWAP[@]}"; do
    dnf5 -y distro-sync --repo="$repo" ${PKGS_TO_SWAP[$repo]}
done
unset -v PKGS_TO_SWAP repo package

# Lock versions for critical system packages
PKGS_TO_LOCK=(
    # GNOME & Display
    gnome-shell

    # Mesa
    mesa-dri-drivers
    mesa-filesystem
    mesa-libEGL
    mesa-libGL
    mesa-libgbm
    mesa-va-drivers
    mesa-vulkan-drivers

    # Firmware
    fwupd
    fwupd-plugin-uefi-capsule-data

    # Other
    switcheroo-control
)

if [ ${#PKGS_TO_LOCK[@]} -gt 0 ]; then
    dnf5 versionlock add "${PKGS_TO_LOCK[@]}"
fi

mkdir -p /etc/xdg/autostart

sed -i 's|grub_probe} --target=device /`|grub_probe} --target=device /sysroot`|g' /usr/bin/grub2-mkconfig

# Patch rtkit
sed -i 's|^ExecStart=.*|ExecStart=/usr/libexec/rtkit-daemon --no-canary|' /usr/lib/systemd/system/rtkit-daemon.service

sed -i 's/balanced=balanced$/balanced=balanced-bazzite/' /etc/tuned/ppd.conf
sed -i 's/performance=throughput-performance$/performance=throughput-performance-bazzite/' /etc/tuned/ppd.conf
sed -i 's/balanced=balanced-battery$/balanced=balanced-battery-bazzite/' /etc/tuned/ppd.conf

sed -i \
  -e '/^\s*#\?\s*AutomaticUpdatePolicy\s*=.*/{s//AutomaticUpdatePolicy=stage/;b}' \
  -e '/^\[Daemon\]/a AutomaticUpdatePolicy=stage' \
  /etc/rpm-ostreed.conf

ln -s /usr/bin/true /usr/bin/pulseaudio

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

echo "::endgroup::"
