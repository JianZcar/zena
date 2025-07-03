#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail
systemctl enable ublue-nvctk-cdi.service
systemctl enable podman.socket ublue-os-media-automount.service
systemctl enable zena-first-boot.service

echo "::endgroup::"
