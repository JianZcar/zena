#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

system_services=(
  nix.mount
  nix-setup.service
  nix-daemon.service
  nix-daemon.socket
  podman.socket
  greetd.service
  chronyd.service
  firewalld.service
  brew-setup.service
  podman-tcp.service
  zena-setup.service
  systemd-homed.service
  systemd-resolved.service
  bootc-fetch-apply-updates.service
)

user_services=(
  dms.service
  dsearch.service
  podman.socket
  gnome-keyring-daemon.socket
  gnome-keyring-daemon.service
)

mask_services=(
  logrotate.timer
  logrotate.service
  rpm-ostree-countme.timer
  rpm-ostree-countme.service
  systemd-remount-fs.service
  flatpak-add-fedora-repos.service
)

systemctl enable "${system_services[@]}"
systemctl mask "${mask_services[@]}"
systemctl --global enable "${user_services[@]}"

preset_file="/usr/lib/systemd/system-preset/01-zena.preset"
touch "$preset_file"

for service in "${system_services[@]}"; do
  echo "enable $service" >> "$preset_file"
done

mkdir -p "/etc/systemd/user-preset/"
preset_file="/etc/systemd/user-preset/01-zena.preset"
touch "$preset_file"

for service in "${user_services[@]}"; do
  echo "enable $service" >> "$preset_file"
done

systemctl --global preset-all

echo "::endgroup::"
