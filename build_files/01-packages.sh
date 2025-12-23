#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

# Base Packages
packages=(
  base
  dracut

  linux-cachyos-bore
  linux-cachyos-bore-headers
  linux-cachyos-bore-nvidia-open
  linux-firmware

  ostree
  bootc
  systemd
  btrfs-progs
  e2fsprogs
  xfsprogs
  binutils
  dosfstools
  skopeo
  dbus
  dbus-glib
  glib2
  shadow
  polkit

  power-profiles-daemon
)
pacman -S --noconfirm "${packages[@]}"

# Drivers
packages=(
  intel-ucode

  mesa
  vulkan-intel
  intel-media-driver
  libva-intel-driver

  nvidia-utils
  nvidia-settings
  opencl-nvidia

  vulkan-icd-loader
  vulkan-tools

  libglvnd
  mesa-utils
)
pacman -S --noconfirm "${packages[@]}"

# Network Drivers
packages=(
  libmtp
  nss-mdns
  samba
  smbclient
  networkmanager
  firewalld
  udiskie
  udisks2
  bluez
  bluez-utils
  iw
  wpa_supplicant
  wireless_tools
  rfkill
)
pacman -S --noconfirm "${packages[@]}"

# Audio Drivers
packages=(
  pipewire
  pipewire-pulse
  pipewire-zeroconf
  pipewire-ffado
  pipewire-libcamera
  sof-firmware
  wireplumber
  alsa-firmware
  pipewire-audio
  linux-firmware-intel
)
pacman -S --noconfirm "${packages[@]}"

# Media/Install utilities/Media drivers
packages=(
  librsvg
  libglvnd
  qt6-multimedia
  qt6-multimedia-ffmpeg
  plymouth
  acpid
  dmidecode
  mesa-utils
  ntfs-3g
  vulkan-tools
  wayland-utils
  playerctl
)
pacman -S --noconfirm "${packages[@]}"

# CLI Utilities
packages=(
  sudo
  bash
  bash-completion
  git
  jq
  less
  lsof
  nano
  openssh
  man-db
  wget
  tree
  usbutils
  vim
  glibc-locales
  tar
  udev
  curl
  unzip
)
pacman -S --noconfirm "${packages[@]}"

# For AUR packages to be remove later
pacman -Sy --noconfirm --needed base-devel paru rust

# Make a build user for AUR
useradd -m -s /bin/bash build
usermod -L build

echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-build-aur
chmod 0440 /etc/sudoers.d/99-build-aur

# Extras
packages=(
  cachyos-settings
  flatpak-git
  podman
)
pacman -S --noconfirm "${packages[@]}"

aur_packages=(
  bootupd-git
)
aur_packages_str="${aur_packages[*]}"

su - build -c "
set -xeuo pipefail
paru -S --noconfirm --needed $aur_packages_str
"

mkdir -p /etc/flatpak/remotes.d/
curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

echo "::endgroup::"
