#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

# Clean /root
rm -rf /root/*
# Uninstall
packages=(
  console-login-helper-messages
  chrony
  qemu-user-static*
  toolbox
)
dnf5 -y remove "${packages[@]}"

packages=(
  @core
  @multimedia
  @base-graphical
  @hardware-support
  @container-management
  @networkmanager-submodules
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
)

# dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False
systemctl mask systemd-remount-fs
systemctl set-default graphical.target

echo "::endgroup::"
