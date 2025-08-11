#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

services=(
  ublue-os-media-automount.service
  zena-first-boot.service
  tailscaled.service
)

for service in "${services[@]}"; do
  systemctl enable "$service"
done

user_services=(
  opentabletdriver.service
  zena-first-boot-gui.service
)

for service in "${user_services[@]}"; do
  systemctl --global enable "$service"
done

echo "::endgroup::"
