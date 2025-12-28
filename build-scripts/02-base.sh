#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  @fonts
  @multimedia
  @hardware-support
  @container-management
  @networkmanager-submodules

  ananicy-cpp
  power-profiles-daemon
  ksmtuned

  # Optimization
  cachyos-ananicy-rules
  cachyos-ksm-settings
  cachyos-settings
  scx-scheds
  scx-manager
  scx-tools
  scxctl

  firewalld

  ublue-brew
  flatpak
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
)
# dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
  console-login-helper-messages
  chrony
  qemu-user-static*
  toolbox
)
dnf5 -y remove "${packages[@]}"

systemctl set-default graphical.target

echo "::endgroup::"
