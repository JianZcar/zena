#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

system_services=(
  group-fix
  systemd-homed
  systemd-resolved
  NetworkManager
  bluetooth
  firewalld

  dms-greeter-cache
  update-bootc-remote
)
systemctl enable "${system_services[@]}"

echo "::endgroup::"
