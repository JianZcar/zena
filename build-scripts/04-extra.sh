#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

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
