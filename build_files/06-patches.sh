#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Define repositories and the packages to be swapped from them
declare -A PKGS_TO_SWAP=(
    ["terra-extras"]="switcheroo-control gnome-shell"
    ["terra-mesa"]="mesa-filesystem"
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
    mutter
    xorg-x11-server-Xwayland

    # Pipewire
    pipewire
    pipewire-alsa
    pipewire-gstreamer
    pipewire-jack-audio-connection-kit
    pipewire-jack-audio-connection-kit-libs
    pipewire-libs
    pipewire-plugin-libcamera
    pipewire-pulseaudio
    pipewire-utils
    wireplumber
    wireplumber-libs

    # Bluetooth
    bluez
    bluez-cups
    bluez-libs
    bluez-obexd

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
    fwupd-plugin-flashrom
    fwupd-plugin-modem-manager
    fwupd-plugin-uefi-capsule-data

    # Other
    switcheroo-control
)

dnf5 versionlock add "${PKGS_TO_LOCK[@]}"

echo "::endgroup::"
