#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

add_wants_niri() {
  sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}

system_services=(
  auditd.service
  greetd.service
  firewalld.service
  podman-tcp.service
  podman.socket
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
  systemd-remount-fs.service
  flatpak-add-fedora-repos.service
  rpm-ostree-countme.service
  rpm-ostree-countme.timer
  logrotate.service
  logrotate.timer
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
