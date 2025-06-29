#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
  # Development Tools
  nvim
  tree-sitter
  ripgrep
  udica

  # Shell
  fish

  # Dotfile management
  stow

  # Fonts
  twitter-twemoji-fonts
  lato-fonts
  fira-code-fonts
  nerd-fonts

  # System Utilities
  btop
  duf
  fastfetch
  glow
  gum
  topgrade
  duperemove
  lzip
  p7zip
  p7zip-plugins
  rar
  f3 # Flash memory tester
  snapper # BTRFS snapshot management
  btrfs-assistant # BTRFS GUI tool

  # Hardware Tools & Drivers
  iwd # iNet Wireless Daemon
  ddcutil # DDC/CI control for monitors
  input-remapper
  i2c-tools
  lm_sensors
  libcec # HDMI CEC library

  # Display & Graphics
  xwininfo
  xrandr
  vulkan-tools
  extest.i686 # X extension tester
  cage # Wayland compositor for single applications
  wlr-randr # Wayland output management

  # Multimedia & Audio
  ladspa-caps-plugins
  ladspa-noise-suppression-for-voice
  pipewire-module-filter-chain-sofa

  # Networking
  tailscale # VPN

  # Virtualization
  edk2-ovmf # UEFI firmware for QEMU
  qemu
  libvirt

  # Other Utilities
  cpulimit
  xdotool
  wmctrl
  yad # Dialogs for shell scripts
  lsb_release
  uupd # Unified Update Platform Downloader
  ydotool # Simulate keyboard/mouse input
  stress-ng # Stress test system
)

PKGS_TO_UNINSTALL=(
  firefox
  firefox-langpacks
  htop
)

# Install packages from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

# Uninstall packages
if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

sed -i 's|uupd|& --disable-module-distrobox|' /usr/lib/systemd/system/uupd.service

dnf5 -y install \
    "$(curl -s https://api.github.com/repos/bazzite-org/cicpoffs/releases/latest \
        | jq -r '.assets[] | select(.name | test(".*rpm$")) | .browser_download_url')"

mkdir -p /etc/xdg/autostart


sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

curl -Lo /usr/bin/installcab https://raw.githubusercontent.com/bazzite-org/steam-proton-mf-wmv/master/installcab.py
chmod +x /usr/bin/installcab

curl -Lo /usr/bin/install-mf-wmv https://github.com/bazzite-org/steam-proton-mf-wmv/blob/master/install-mf-wmv.sh
chmod +x /usr/bin/install-mf-wmv

curl -Lo /tmp/ls-iommu.tar.gz "$(curl -s https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest \
    | jq -r '.assets[] | select(.name | test(".*x86_64.tar.gz$")) | .browser_download_url')"
mkdir -p /tmp/ls-iommu
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu
cp -r /tmp/ls-iommu/ls-iommu /usr/bin/
rm -rf /tmp/ls-iommu*

SCOPEBUDDY_TAG=$(curl -s https://api.github.com/repos/HikariKnight/scopebuddy/releases/latest | jq -r '.tag_name')
curl -Lo /tmp/scopebuddy.tar.gz "https://github.com/HikariKnight/scopebuddy/archive/refs/tags/${SCOPEBUDDY_TAG}.tar.gz"
mkdir -p /tmp/scopebuddy
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/scopebuddy.tar.gz -C /tmp/scopebuddy
cp -r /tmp/scopebuddy/ScopeBuddy-*/bin/* /usr/bin/
rm -rf /tmp/scopebuddy*

systemctl enable podman.socket

echo "::endgroup::"
