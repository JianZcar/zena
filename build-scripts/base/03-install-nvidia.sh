#!/usr/bin/bash
set -eoux pipefail

echo "::group::===$(basename "$0")==="
trap 'echo "::endgroup::"' EXIT

IMAGE_NAME="${BASE_IMAGE_NAME}"
RELEASE="$(rpm -E %fedora)"

dnf5 -y copr enable ublue-os/staging
dnf5 -y install \
  mesa-vdpau-drivers.x86_64 \
  mesa-vdpau-drivers.i686 
  
# disable any remaining rpmfusion repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion*.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

rpm-ostree install /tmp/rpms/ublue-os/ublue-os-nvidia*.rpm

# enable repos provided by ublue-os-nvidia-addons
sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/negativo17-fedora-nvidia.repo
sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Disable Multimedia
NEGATIVO17_MULT_PREV_ENABLED=N
if [[ -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo &&  -n $(grep enabled=1 /etc/yum.repos.d/negativo17-fedora-multimedia.repo) ]]; then
    NEGATIVO17_MULT_PREV_ENABLED=Y
    echo "disabling negativo17-fedora-multimedia to ensure negativo17-fedora-nvidia is used"
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
fi

# Enable staging for supergfxctl if repo file exists
if [[ -f /etc/yum.repos.d/_copr_ublue-os-staging.repo ]]; then
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo
else
    # Otherwise, retrieve the repo file for staging
    curl -Lo /etc/yum.repos.d/_copr_ublue-os-staging.repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${RELEASE}"/ublue-os-staging-fedora-"${RELEASE}".repo
fi

source /tmp/rpms/kmods/nvidia-vars

dnf5 install -y \
    libnvidia-fbc \
    libnvidia-ml.i686 \
    libva-nvidia-driver \
    mesa-vulkan-drivers.i686 \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-driver-cuda-libs.i686 \
    nvidia-driver-libs.i686 \
    nvidia-settings \
    nvidia-container-toolkit gnome-shell-extension-supergfxctl-gex supergfxctl
rpm-ostree install /tmp/rpms/kmods/kmod-nvidia*.rpm

## nvidia post-install steps
# disable repos provided by ublue-os-nvidia-addons
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Disable staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo

# ensure kernel.conf matches NVIDIA_FLAVOR (which must be nvidia or nvidia-open)
# kmod-nvidia-common defaults to 'nvidia-open' but this will match our akmod image
sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=$KERNEL_MODULE_TYPE/" /etc/nvidia/kernel.conf

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# re-enable negativo17-mutlimedia since we disabled it
if [[ "${NEGATIVO17_MULT_PREV_ENABLED}" = "Y" ]]; then
    sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
fi

rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json

ln -s libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
dnf5 -y copr disable ublue-os/staging
