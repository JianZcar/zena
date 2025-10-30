#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

services=(
    ublue-os-media-automount.service
    zena-first-boot.service
    tailscaled.service
)

user_services=(
    opentabletdriver.service
    zena-first-boot-gui.service
)

systemctl enable "${services[@]}"
systemctl --global enable "$user_services"

echo "::endgroup::"
