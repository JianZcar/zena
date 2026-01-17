#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
  nvidia-driver-cuda
  libnvidia-fbc
  libva-nvidia-driver
  nvidia-driver
  nvidia-modprobe
  nvidia-persistenced
  nvidia-settings
)

KVER=$(ls /usr/lib/modules | head -n1)

dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-nvidia.repo
dnf5 config-manager setopt "*rpmfusion*".enabled=0
dnf5 config-manager setopt fedora-nvidia.enabled=0
sed -i '/^enabled=/a\priority=90' /etc/yum.repos.d/fedora-nvidia.repo

dnf5 -y install --enablerepo=fedora-nvidia akmod-nvidia

mkdir -p /var/tmp
chmod 1777 /var/tmp

akmods --force --kernels "${KVER}" --kmod "nvidia"
cat /var/cache/akmods/nvidia/*.failed.log || true

dnf5 -y install --enablerepo=fedora-nvidia "${packages[@]}"
dnf5 versionlock add "${packages[@]}"

dnf5 config-manager addrepo --from-repofile=https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
dnf5 config-manager setopt nvidia-container-toolkit.enabled=0
dnf5 config-manager setopt nvidia-container-toolkit.gpgcheck=1

dnf5 -y install --enablerepo=nvidia-container-toolkit \
    nvidia-container-toolkit

curl --retry 3 -L https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp -o nvidia-container.pp
semodule -i nvidia-container.pp
rm -f nvidia-container.pp
rm /etc/xdg/autostart/nvidia-settings-load.desktop

systemctl enable nvctk-cdi.service

preset_file="/usr/lib/systemd/system-preset/01-zena.preset"
touch "$preset_file"
echo "enable nvctk-cdi.service" >> "$preset_file"

echo "::endgroup::"
