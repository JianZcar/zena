#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Define repositories and the packages to be swapped from them
declare -A toswap=(
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite"]="wireplumber"
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite-multilib"]="bluez xorg-x11-server-Xwayland mutter"
    ["terra-extras"]="switcheroo-control gnome-shell"
    ["terra-mesa"]="mesa-filesystem"
    ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd"
)

# Swap packages from the specified repositories
for repo in "${!toswap[@]}"; do
    for package in ${toswap[$repo]}; do
        dnf5 -y swap --repo="$repo" "$package" "$package"
    done
done
unset -v toswap repo package

# Lock versions for critical system packages
PKGS_TO_LOCK=(
    # GNOME
    gnome-shell
    mutter

    pipewire
    pipewire-alsa
    pipewire-alsa.i686
    pipewire-gstreamer
    pipewire-jack-audio-connection-kit
    pipewire-jack-audio-connection-kit-libs
    pipewire-libs
    pipewire-plugin-libcamera
    pipewire-pulseaudio
    pipewire-utils
    wireplumber
    wireplumber-libs
    bluez
    bluez-cups
    bluez-libs
    bluez-obexd
    xorg-x11-server-Xwayland
    switcheroo-control
    mesa-dri-drivers
    mesa-filesystem
    mesa-libEGL
    mesa-libGL
    mesa-libgbm
    mesa-va-drivers
    mesa-vulkan-drivers
    fwupd
    fwupd-plugin-flashrom
    fwupd-plugin-modem-manager
    fwupd-plugin-uefi-capsule-data
)

if [ ${#PKGS_TO_LOCK[@]} -gt 0 ]; then
    dnf5 versionlock add "${PKGS_TO_LOCK[@]}"
fi

echo "::endgroup::"
