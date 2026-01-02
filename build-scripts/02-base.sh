#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  ############################
  # Hardware Support + Core #
  ############################
  @hardware-support
  @container-management
  steam-devices

  ############################
  # WIFI / WIRELESS FIRMWARE #
  ############################
  @networkmanager-submodules
  NetworkManager-wifi

  atheros-firmware
  brcmfmac-firmware
  iwlegacy-firmware
  iwlwifi-dvm-firmware
  iwlwifi-mvm-firmware
  mt7xxx-firmware
  nxpwireless-firmware
  realtek-firmware
  tiwilink-firmware

  ############################
  # AUDIO / SOUND FIRMWARE   #
  ############################
  alsa-firmware
  alsa-sof-firmware
  intel-audio-firmware

  ############################
  # SYSTEM / CORE UTILITIES  #
  ############################
  audit
  audispd-plugins
  cifs-utils
  firewalld
  fuse
  fuse-common
  fuse-devel
  fwupd
  man-db
  man-pages
  systemd-container
  unzip
  whois
  inotify-tools
  gum
  xdg-user-dirs
  xdg-user-dirs-gtk

  ############################
  # DESKTOP PORTALS          #
  ############################
  xdg-desktop-portal
  xdg-desktop-portal-gnome

  ############################
  # MOBILE / CAMERA SUPPORT #
  ############################
  gvfs-mtp
  gvfs-smb
  ifuse
  jmtpfs

  libcamera
  libcamera-v4l2
  libcamera-gstreamer
  libcamera-tools

  libimobiledevice

  ############################
  # AUDIO SYSTEM (PIPEWIRE)  #
  ############################
  pipewire
  pipewire-pulseaudio
  pipewire-alsa
  pipewire-jack-audio-connection-kit
  wireplumber
  pipewire-plugin-libcamera

  ############################
  # DEVTOOLS / CLI UTILITIES #
  ############################
  git
  yq

  ############################
  # DISPLAY + MULTIMEDIA     #
  ############################
  @multimedia
  ffmpeg
  libavcodec
  gstreamer1-plugins-base
  gstreamer1-plugins-good
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-free-libs
  qt6-qtmultimedia
  lame-libs
  libjxl
  ffmpegthumbnailer
  glycin-thumbnailer
  webp-pixbuf-loader

  ############################
  # FONTS / LOCALE SUPPORT   #
  ############################
  @fonts
  glibc-all-langpacks

  ############################
  # Performance              #
  ############################
  power-profiles-daemon
  ksmtuned
  cachyos-ksm-settings
  cachyos-settings
  scx-manager
  scx-scheds
  scx-tools
  scxctl

  ############################
  # GRAPHICS / VULKAN        #
  ############################
  mesa*
  *vulkan*

  ############################
  # PACKAGE MANAGERS         #
  ############################
  flatpak
  nix
  nix-daemon
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

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

tar --create --verbose --preserve-permissions \
  --same-owner \
  --file /etc/nix-setup.tar \
  -C / nix

rm -rf /nix/* /nix/.[!.]*

# So it won't reboot on Update
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

echo "::endgroup::"
