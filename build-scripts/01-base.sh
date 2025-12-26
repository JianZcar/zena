#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  @core
  @multimedia
  @base-graphical
  @hardware-support
  @container-management
  @networkmanager-submodules

  fedora-release-ostree-desktop
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
  sssd*
  qemu-user-static*
  toolbox
)
dnf5 -y remove "${packages[@]}"

systemctl mask systemd-remount-fs
systemctl set-default graphical.target

echo "::endgroup::"
