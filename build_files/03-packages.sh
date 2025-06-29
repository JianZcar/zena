#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
  # Development
  nvim
  ripgrep
  tree-sitter
  udica

  # Shell & Dotfiles
  fish
  stow

  # Fonts
  fira-code-fonts
  lato-fonts
  nerd-fonts
  twitter-twemoji-fonts

  # System Utilities
  btop
  duf
  fastfetch
  glow
  gum
  p7zip
  p7zip-plugins
  rar
  topgrade

  # File System & Storage
  btrfs-assistant # BTRFS GUI tool
  duperemove
  f3 # Flash memory tester
  lzip
  snapper # BTRFS snapshot management

  # Hardware & Drivers
  ddcutil # DDC/CI control for monitors
  i2c-tools
  input-remapper
  iwd # iNet Wireless Daemon
  libcec # HDMI CEC library
  lm_sensors

  # Display & Graphics
  cage # Wayland compositor for single applications
  extest.i686 # X extension tester
  vulkan-tools
  wlr-randr # Wayland output management
  xrandr
  xwininfo

  # Multimedia & Audio
  ladspa-caps-plugins
  ladspa-noise-suppression-for-voice

  # Networking
  tailscale

  # Virtualization
  edk2-ovmf # UEFI firmware for QEMU
  libvirt
  qemu

  # GNOME
  gnome-randr-rust
  gnome-shell-extension-appindicator
  gnome-shell-extension-blur-my-shell
  gnome-shell-extension-burn-my-windows
  gnome-shell-extension-caffeine
  gnome-shell-extension-compiz-windows-effect
  gnome-shell-extension-gsconnect
  gnome-shell-extension-hotedge
  gnome-shell-extension-just-perfection
  gnome-shell-extension-restart-to
  gnome-shell-extension-user-theme
  nautilus-gsconnect

  # Miscellaneous
  cpulimit
  firewall-config
  lsb_release
  openssh-askpass
  stress-ng # Stress test system
  uupd # Unified Update Platform Downloader
  wmctrl
  xdotool
  yad # Dialogs for shell scripts
  ydotool # Simulate keyboard/mouse input
)

PKGS_TO_UNINSTALL=(
  pipewire-libs
  firefox
  firefox-langpacks
  htop
  gnome-classic-session
  gnome-tour
  gnome-extensions-app
  gnome-system-monitor
  gnome-initial-setup
  gnome-browser-connector
  gnome-shell-extension-background-logo
  gnome-shell-extension-apps-menu
)

# Install packages from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

# Uninstall packages
if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi


# Install multimedia libraries from RPM Fusion
dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
    libaacs \
    libbdplus \
    libbluray \
    libbluray-utils

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
