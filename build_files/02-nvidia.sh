#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

: "${AKMODNV_PATH:=/tmp/akmods-rpms}"
dnf5 install -y "${AKMODNV_PATH}"/ublue-os/ublue-os-nvidia-addons-*.rpm

dnf5 -y install \
    egl-wayland2.x86_64 \
    egl-wayland2.i686 && \

dnf5 install -y \
    /rpms/nvidia/libnvidia-cfg-* \
    /rpms/nvidia/libnvidia-fbc-* \
    /rpms/nvidia/libnvidia-gpucomp-* \
    /rpms/nvidia/libnvidia-ml-* \
    /rpms/nvidia/nvidia-driver-* \
    /rpms/nvidia/nvidia-kmod-common-* \
    /rpms/nvidia/nvidia-modprobe-5* \
    /rpms/nvidia/nvidia-persistenced-5* \
    /rpms/nvidia/xorg-x11* \
    /rpms/nvidia/nvidia-container-toolkit-1* \
    /rpms/nvidia/nvidia-container-toolkit-base-1* \
    /rpms/nvidia/libnvidia-container1-1* \
    /rpms/nvidia/libnvidia-container-tools-1* \
    supergfxctl

semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json

ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so

echo "::endgroup::"
