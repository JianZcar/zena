#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  gh
  fish
  starship
  fastfetch

  bazaar
  ghostty
  nautilus
  nautilus-python
  firewall-config

  zen-browser

  gamescope
  obs-studio-plugin-vkcapture
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
  steam
  lutris
)
dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

echo "::endgroup::"
