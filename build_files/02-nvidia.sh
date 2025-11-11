#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

FRELEASE=$(rpm -E %fedora)

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
    /rpms/nvidia/libnvidia-container-tools-1*

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

echo "::endgroup::"
