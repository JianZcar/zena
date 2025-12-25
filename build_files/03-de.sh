#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
    greetd
    greetd-selinux

    quickshell-git
    dms
    dms-greeter
    danksearch
    dgop

    gnome-keyring
    gnome-keyring-pam

    wl-clipboard

    xwayland-satellite

    morewaita-icon-theme
    material-symbols-fonts

    cliphist
    matugen
    cava
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
    niri
    adw-gtk3-theme
)

dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

echo "::endgroup::"
