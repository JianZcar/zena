#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

services=(
  ublue-nvctk-cdi.service
  podman.socket
  ublue-os-media-automount.service
  zena-first-boot.service
  tailscaled.service
  opentabletdriver.service
)

for service in "${services[@]}"; do
  systemctl enable "$service"
done

echo "::endgroup::"
