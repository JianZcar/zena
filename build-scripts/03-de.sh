#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  gnome-keyring
  gnome-keyring-pam

  greetd
  dms-greeter
  greetd-selinux

  dms
  dgop
  danksearch
  quickshell-git

  adw-gtk3-theme
  xwayland-satellite

  cava
  matugen
  cliphist
  wl-clipboard
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
