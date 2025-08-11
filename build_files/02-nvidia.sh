#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"
: "${AKMODNV_PATH:=/tmp/akmods-rpms}"

dnf5 -y install mesa-vdpau-drivers.x86_64 mesa-vdpau-drivers.i686
dnf5 config-manager setopt "rpmfusion*".enabled=false fedora-cisco-openh264.enabled=false

dnf5 install -y "${AKMODNV_PATH}"/ublue-os/ublue-os-nvidia-addons-*.rpm

MULTILIB_PKGS_TO_INSTALL=(
    mesa-dri-drivers.i686
    mesa-libEGL.i686
    mesa-libGL.i686
    mesa-libgbm.i686
    mesa-va-drivers.i686
    mesa-vulkan-drivers.i686
)

dnf5 install -y "${MULTILIB_PKGS_TO_INSTALL[@]}"

dnf5 config-manager setopt fedora-nvidia.enabled=true nvidia-container-toolkit.enabled=true
dnf5 config-manager setopt fedora-multimedia.enabled=false

source "${AKMODNV_PATH}"/kmods/nvidia-vars

PKGS_TO_INSTALL=(
    nvidia-driver
    nvidia-driver-libs
    nvidia-driver-cuda
    nvidia-driver-cuda-libs

    nvidia-driver-libs.i686
    nvidia-driver-cuda-libs.i686

    nvidia-settings
    nvidia-container-toolkit
    "${AKMODNV_PATH}"/kmods/kmod-nvidia-"${KERNEL_VERSION}"-"${NVIDIA_AKMOD_VERSION}"."${DIST_ARCH}".rpm

    libnvidia-fbc
    libnvidia-ml.i686
    libva-nvidia-driver

    supergfxd
    gnome-shell-extension-supergfxctl-gex
)

dnf5 install -y "${PKGS_TO_INSTALL[@]}"

# Ensure the version of the Nvidia module matches the driver
KMOD_VERSION="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}' kmod-nvidia)"
DRIVER_VERSION="$(rpm -q --queryformat '%{VERSION}-%{RELEASE}' nvidia-driver)"
if [ "$KMOD_VERSION" != "$DRIVER_VERSION" ]; then
    echo "Error: kmod-nvidia version ($KMOD_VERSION) does not match nvidia-driver version ($DRIVER_VERSION)"
    exit 1
fi

dnf5 config-manager setopt nvidia-container-toolkit.enabled=false

sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=$KERNEL_MODULE_TYPE/" /etc/nvidia/kernel.conf
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

dnf5 config-manager setopt fedora-multimedia.enabled=true

rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
echo "::endgroup::"
