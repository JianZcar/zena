#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

dnf5 -y copr enable ublue-os/staging && \
dnf5 -y install \
    mesa-vdpau-drivers.x86_64 \
    mesa-vdpau-drivers.i686 && \
curl -Lo /tmp/nvidia-install.sh https://raw.githubusercontent.com/ublue-os/hwe/b3a3dbddf4af81cfbfa7526c1918c9b9f014f86b/nvidia-install.sh && \
chmod +x /tmp/nvidia-install.sh 
IMAGE_NAME="${BASE_IMAGE_NAME}" 
/tmp/nvidia-install.sh && \
rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json && \
ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so && \
dnf5 -y copr disable ublue-os/staging
