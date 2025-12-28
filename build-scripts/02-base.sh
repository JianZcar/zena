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

  xdg-user-dirs
  xdg-user-dirs-gtk

  ananicy-cpp
  power-profiles-daemon
  ksmtuned

  # Optimization
  cachyos-ananicy-rules
  cachyos-ksm-settings
  cachyos-settings
  ananicy-cpp
  scx-manager
  scx-scheds
  scx-tools
  scxctl

  mesa*
  *vulkan*

  firewalld

  man-db
  man-pages

  git
  flatpak

  gum
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
)
# dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
  console-login-helper-messages
  qemu-user-static*
  toolbox
)
dnf5 -y remove "${packages[@]}"

systemctl set-default graphical.target

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

echo "::endgroup::"
