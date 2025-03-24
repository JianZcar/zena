#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

IMAGE_NAME="${BASE_IMAGE_NAME}"

dnf5 -y copr enable ublue-os/staging
dnf5 -y install \
    mesa-vdpau-drivers.x86_64 \
    mesa-vdpau-drivers.i686 
    
rpm-ostree install /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm
rpm-ostree install /tmp/rpms/kmods/kmod-nvidia*.rpm

rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json

ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
dnf5 -y copr disable ublue-os/staging
