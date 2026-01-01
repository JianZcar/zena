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

  power-profiles-daemon
  ksmtuned

  # Optimization
  cachyos-ksm-settings
  cachyos-settings
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
authselect select sssd with-systemd-homed with-faillock without-nullok
authselect apply-changes

useradd -u 350 --system --no-create-home --shell /usr/sbin/nologin linuxbrew

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

# So it won't reboot on Update
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

mkdir /nix

echo "::endgroup::"
