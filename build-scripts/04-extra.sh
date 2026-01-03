#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  fastfetch
  gh

  bazaar
  firewall-config
  ghostty
  nautilus
  nautilus-python
  zen-browser

  gamescope
  v4l2loopback
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
  lutris
  steam
)
dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

echo "::endgroup::"
