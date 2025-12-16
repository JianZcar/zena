#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

cat << 'EOF' > /usr/share/libalpm/hooks/package-cleanup.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleaning up package cache...
Depends = coreutils
When = PostTransaction
Exec = /usr/bin/rm -rf /var/cache/pacman/pkg
EOF

pacman-key --init
pacman -Syu --noconfirm
pacman -S --noconfirm reflector

pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

cat <<EOF > /tmp/cachyos-repos
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

EOF

cat <<EOF >> /etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

cat /etc/pacman.conf
cat /etc/pacman.conf >> /tmp/cachyos-repos
mv /tmp/cachyos-repos /etc/pacman.conf

pacman -Sy --noconfirm pacman
pacman -S --noconfirm $(pacman -Qq)

# Base Packages
packages=(
  base
  dracut
  chaotic-aur/bootc

  linux-cachyos-bore
  linux-cachyos-bore-headers
  linux-cachyos-bore-nvidia
  linux-firmware

  ostree
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

packages=(
  flatpak-git
)
pacman -S --noconfirm "${packages[@]}"

cat <<'EOF' > /etc/sudoers.d/00-sudo-config
%wheel ALL=(ALL:ALL) ALL

Defaults pwfeedback
Defaults secure_path="/usr/local/bin:/usr/bin:/bin:/home/linuxbrew/.linuxbrew/bin"
Defaults env_keep += "EDITOR VISUAL PATH"
Defaults timestamp_timeout=0
EOF
chmod 440 /etc/sudoers.d/00-sudo-config

cat <<'EOF' > /usr/libexec/group-fix
#!/bin/sh

cat /usr/lib/sysusers.d/*.conf \
  | grep -e "^g" \
  | grep -v -e "^#" \
  | awk "NF" \
  | awk '{print $2}' \
  | grep -v -e "wheel" -e "root" -e "sudo" \
  | xargs -I{} sed -i "/{}/d" "$1"
EOF
chmod +x /usr/libexec/group-fix

cat <<'EOF' > /usr/lib/systemd/system/group-fix.service
[Unit]
Description=Fix system groups
Wants=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/libexec/group-fix /etc/group
ExecStart=/usr/libexec/group-fix /etc/gshadow
ExecStart=systemd-sysusers

[Install]
WantedBy=default.target
WantedBy=multi-user.target
EOF

cat <<'EOF' > /usr/lib/systemd/system-preset/01-group-fix.preset
enable group-fix.service
EOF

curl -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
echo "Default=true" | tee -a /etc/flatpak/remotes.d/flathub.flatpakrepo > /dev/null
flatpak remote-add --if-not-exists --system flathub /etc/flatpak/remotes.d/flathub.flatpakrepo
flatpak remote-modify --system --enable flathub

system_services=(
  group-fix
  systemd-homed
  systemd-resolved
  NetworkManager
  bluetooth
  firewalld
)
systemctl enable "${system_services[@]}"

echo "::endgroup::"
