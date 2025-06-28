#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

PKGS_TO_INSTALL=(
  # Development Tools
  ripgrep
  udica

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

systemctl enable podman.socket

echo "::endgroup::"
