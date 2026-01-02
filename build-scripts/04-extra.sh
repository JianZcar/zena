#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

dnf5 -y install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

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
  v4l2loopback
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
