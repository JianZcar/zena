#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

dnf5 -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

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

  gamescope.x86_64
  gamescope-libs.x86_64
  gamescope-libs.i686
  gamescope-shaders
  jupiter-sd-mounting-btrfs
  umu-launcher
  dbus-x11
  xdg-user-dirs
  gobject-introspection
  libFAudio.x86_64
  libFAudio.i686
  vkBasalt.x86_64
  vkBasalt.i686
  mangohud.x86_64
  mangohud.i686
  libobs_vkcapture.x86_64
  libobs_glcapture.x86_64
  libobs_vkcapture.i686
  libobs_glcapture.i686
  openxr
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
